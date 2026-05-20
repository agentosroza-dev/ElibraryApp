<?php
namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\Manage\DetailUserResource;
use App\Http\Resources\UserResource;
use App\Models\User;
use Carbon\Carbon;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use App\Models\Item;
use App\Models\Tag;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Collection;

class UserController extends Controller
{
    private const DEFAULT_LIMIT = 4;
    private const MAX_LIMIT = 24;

    private const TITLE_WORD_SCORE = 20;
    private const SAME_CATEGORY_SCORE = 10;
    private const BASE_TAG_SCORE = 8;

    private const FAVORITE_SCORE = 15;
    private const OVERALL_FAVORITE_SCORE = 25;

    private const USER_INTEREST_BASE_SCORE = 10;
    private const FAVORITE_TAG_SCORE_MULTIPLIER = 8;
    private const VIEWED_TAG_SCORE_MULTIPLIER = 1;

    public function getUserTagInterests(Request $request): JsonResponse
    {
        $userId = (int) optional($request->user())->id;

        if ($userId <= 0) {
            return response()->json([
                'data' => [],
            ]);
        }

        $rows = $this->getUserInterestScoreMap($userId)
            ->map(function ($score, $tagId) {
                return [
                    'tag_id' => (int) $tagId,
                    'total_score' => (int) $score,
                ];
            })
            ->sortByDesc('total_score')
            ->values();

        return response()->json([
            'data' => $rows,
        ]);
    }

    public function getRecommendedBooks(Request $request): JsonResponse
    {
        $userId = (int) optional($request->user())->id;
        $limit = $this->resolveLimit($request);

        if ($userId <= 0) {
            return response()->json([
                'data' => [],
            ]);
        }

        $userInterestScores = $this->getUserInterestScoreMap($userId);

        if ($userInterestScores->isEmpty()) {
            return response()->json([
                'data' => [],
            ]);
        }

        $favoriteIdSet = $this->getFavoriteIdSet($userId);
        $books = $this->getBaseBookRows();
        $bookIds = $books->pluck('id')->map(fn ($id) => (int) $id)->all();
        $tagsByBook = $this->getTagsByBookIds($bookIds);

        $data = $books
            ->map(function ($row) use ($userInterestScores, $favoriteIdSet, $tagsByBook) {
                $bookId = (int) $row->id;
                $tagIds = $this->getBookTagIds($bookId, $tagsByBook);

                [$matchedTagScore, $matchedTagCount] = $this->calculateTagMatchMetrics(
                    $tagIds,
                    $userInterestScores
                );

                $viewsCount = (int) ($row->views_count ?? 0);
                $favoriteScore = isset($favoriteIdSet[$bookId]) ? self::FAVORITE_SCORE : 0;
                $finalScore = ($matchedTagScore * 10) + ($matchedTagCount * 5) + $viewsCount + $favoriteScore;

                return array_merge(
                    $this->mapBookRow($row, $tagsByBook),
                    [
                        'matched_tag_score' => $matchedTagScore,
                        'matched_tag_count' => $matchedTagCount,
                        'favorite_score' => $favoriteScore,
                        'views_count' => $viewsCount,
                        'final_score' => $finalScore,
                    ]
                );
            })
            ->filter(fn ($row) => (int) $row['final_score'] > 0)
            ->sort(function ($a, $b) {
                if ((int) $b['final_score'] !== (int) $a['final_score']) {
                    return (int) $b['final_score'] <=> (int) $a['final_score'];
                }

                if ((int) $b['matched_tag_score'] !== (int) $a['matched_tag_score']) {
                    return (int) $b['matched_tag_score'] <=> (int) $a['matched_tag_score'];
                }

                if ((int) $b['matched_tag_count'] !== (int) $a['matched_tag_count']) {
                    return (int) $b['matched_tag_count'] <=> (int) $a['matched_tag_count'];
                }

                if ((int) $b['favorite_score'] !== (int) $a['favorite_score']) {
                    return (int) $b['favorite_score'] <=> (int) $a['favorite_score'];
                }

                if ((int) $b['views_count'] !== (int) $a['views_count']) {
                    return (int) $b['views_count'] <=> (int) $a['views_count'];
                }

                return strcasecmp((string) $a['title'], (string) $b['title']);
            })
            ->take($limit)
            ->values();

        return response()->json([
            'data' => $data,
        ]);
    }

    public function getRecommendedOverallBooks(Request $request): JsonResponse
    {
        $userId = (int) optional($request->user())->id;
        $limit = $this->resolveLimit($request);

        $favoriteIdSet = $userId > 0 ? $this->getFavoriteIdSet($userId) : [];
        $userInterestScores = $userId > 0 ? $this->getUserInterestScoreMap($userId) : collect();
        $readProgressMap = $userId > 0 ? $this->getReadProgressPercentMap($userId) : collect();

        $books = $this->getBaseBookRows();
        $bookIds = $books->pluck('id')->map(fn ($id) => (int) $id)->all();
        $tagsByBook = $this->getTagsByBookIds($bookIds);

        $scored = $books
            ->map(function ($row) use ($favoriteIdSet, $userInterestScores, $readProgressMap, $tagsByBook) {
                $bookId = (int) $row->id;
                $tagIds = $this->getBookTagIds($bookId, $tagsByBook);

                [$matchedTagScore, $matchedTagCount] = $this->calculateTagMatchMetrics(
                    $tagIds,
                    $userInterestScores
                );

                $viewsCount = (int) ($row->views_count ?? 0);
                $popularityScore = (int) round(min(log($viewsCount + 1, 2) * 12, 40));
                $favoriteScore = isset($favoriteIdSet[$bookId]) ? self::OVERALL_FAVORITE_SCORE : 0;

                $readProgressPercent = (float) ($readProgressMap[$bookId] ?? 0);
                $readProgressPercent = max(0, min($readProgressPercent, 100));
                $readProgressScore = $this->resolveReadProgressScore($readProgressPercent);

                $recencyScore = $this->resolveRecencyScore($row->updated_at ?? null);

                $finalScore =
                    ($matchedTagScore * 12) +
                    ($matchedTagCount * 8) +
                    $favoriteScore +
                    $readProgressScore +
                    $popularityScore +
                    $recencyScore;

                return array_merge(
                    $this->mapBookRow($row, $tagsByBook),
                    [
                        'views_count' => $viewsCount,
                        'popularity_score' => $popularityScore,
                        'favorite_score' => $favoriteScore,
                        'matched_tag_score' => $matchedTagScore,
                        'matched_tag_count' => $matchedTagCount,
                        'read_progress_percent' => $readProgressPercent,
                        'read_progress_score' => $readProgressScore,
                        'recency_score' => $recencyScore,
                        'final_score' => $finalScore,
                    ]
                );
            })
            ->filter(function ($row) {
                return
                    (int) $row['matched_tag_score'] > 0 ||
                    (int) $row['favorite_score'] > 0 ||
                    (int) $row['popularity_score'] > 0 ||
                    (float) $row['read_progress_percent'] > 0;
            })
            ->sort(function ($a, $b) {
                if ((int) $b['final_score'] !== (int) $a['final_score']) {
                    return (int) $b['final_score'] <=> (int) $a['final_score'];
                }

                if ((int) $b['matched_tag_score'] !== (int) $a['matched_tag_score']) {
                    return (int) $b['matched_tag_score'] <=> (int) $a['matched_tag_score'];
                }

                if ((int) $b['favorite_score'] !== (int) $a['favorite_score']) {
                    return (int) $b['favorite_score'] <=> (int) $a['favorite_score'];
                }

                if ((int) $b['read_progress_score'] !== (int) $a['read_progress_score']) {
                    return (int) $b['read_progress_score'] <=> (int) $a['read_progress_score'];
                }

                if ((int) $b['popularity_score'] !== (int) $a['popularity_score']) {
                    return (int) $b['popularity_score'] <=> (int) $a['popularity_score'];
                }

                return strcasecmp((string) $a['title'], (string) $b['title']);
            })
            ->values();

        $selected = collect();
        $usedAuthors = [];
        $usedCategories = [];

        foreach ($scored as $book) {
            $authorId = (int) ($book['author_id'] ?? 0);
            $categoryId = (int) ($book['category_id'] ?? 0);

            $authorCount = $authorId ? ($usedAuthors[$authorId] ?? 0) : 0;
            $categoryCount = $categoryId ? ($usedCategories[$categoryId] ?? 0) : 0;

            if ($authorCount >= 2 || $categoryCount >= 3) {
                continue;
            }

            $selected->push($book);

            if ($authorId) {
                $usedAuthors[$authorId] = $authorCount + 1;
            }

            if ($categoryId) {
                $usedCategories[$categoryId] = $categoryCount + 1;
            }

            if ($selected->count() >= $limit) {
                break;
            }
        }

        if ($selected->count() < $limit) {
            $selectedIds = $selected->pluck('id')->all();

            $fill = $scored
                ->reject(fn ($book) => in_array($book['id'], $selectedIds, true))
                ->take($limit - $selected->count());

            $selected = $selected->concat($fill)->values();
        }

        return response()->json([
            'data' => $selected->values(),
        ]);
    }

    public function getSimilarTitleBooks(Request $request, int $id): JsonResponse
    {
        $userId = (int) optional($request->user())->id;
        $limit = $this->resolveLimit($request);

        $baseBook = DB::table('items')
            ->select('id', 'title', 'category_id')
            ->where('id', $id)
            ->first();

        if (!$baseBook) {
            return response()->json([
                'data' => [],
                'message' => 'Book not found',
            ], 404);
        }

        $baseWords = collect(preg_split('/\s+/', mb_strtolower((string) $baseBook->title)))
            ->map(fn ($word) => preg_replace('/[^\p{L}\p{N}]+/u', '', $word))
            ->filter(fn ($word) => filled($word) && mb_strlen($word) >= 2)
            ->unique()
            ->values();

        $baseTagIds = DB::table('book_tag')
            ->where('book_id', $id)
            ->pluck('tag_id')
            ->map(fn ($tagId) => (int) $tagId)
            ->filter()
            ->values()
            ->all();

        $favoriteBooks = DB::table('user_favorite_books')
            ->where('user_id', $userId)
            ->select('book_id');

        $rows = DB::table('items')
            ->leftJoinSub($favoriteBooks, 'fav', function ($join) {
                $join->on('items.id', '=', 'fav.book_id');
            })
            ->leftJoin('categories', 'items.category_id', '=', 'categories.id')
            ->leftJoin('users as authors', 'items.author_id', '=', 'authors.id')
            ->where('items.id', '!=', $id)
            ->select([
                'items.id',
                'items.title',
                'items.author_id',
                'items.cover_url',
                'items.file_url',
                'items.category_id',
                'items.created_at',
                'items.updated_at',
                DB::raw('COALESCE(categories.name, "Uncategorized") as category_name'),
                DB::raw('COALESCE(authors.name, "Unknown Author") as author_name'),
                DB::raw('CASE WHEN fav.book_id IS NOT NULL THEN ' . self::FAVORITE_SCORE . ' ELSE 0 END as favorite_score'),
            ])
            ->get();

        if ($rows->isEmpty()) {
            return response()->json([
                'data' => [],
                'base_book' => [
                    'id' => (int) $baseBook->id,
                    'title' => (string) $baseBook->title,
                ],
            ]);
        }

        $candidateBookIds = $rows->pluck('id')
            ->map(fn ($bookId) => (int) $bookId)
            ->all();

        $tagsByBook = $this->getTagsByBookIds($candidateBookIds);

        $data = $rows
            ->map(function ($row) use ($baseBook, $baseWords, $baseTagIds, $tagsByBook) {
                $title = mb_strtolower((string) $row->title);

                $titleMatchScore = 0;
                foreach ($baseWords as $word) {
                    if ($word !== '' && str_contains($title, $word)) {
                        $titleMatchScore += self::TITLE_WORD_SCORE;
                    }
                }

                $sameCategoryScore = (
                    !empty($baseBook->category_id) &&
                    (int) $row->category_id === (int) $baseBook->category_id
                ) ? self::SAME_CATEGORY_SCORE : 0;

                $bookTagIds = $this->getBookTagIds((int) $row->id, $tagsByBook);

                $baseTagMatchCount = empty($baseTagIds)
                    ? 0
                    : count(array_intersect($baseTagIds, $bookTagIds));

                $baseTagScore = $baseTagMatchCount * self::BASE_TAG_SCORE;
                $favoriteScore = (int) ($row->favorite_score ?? 0);

                $finalScore =
                    $titleMatchScore +
                    $sameCategoryScore +
                    $baseTagScore +
                    $favoriteScore;

                return [
                    'id' => (int) $row->id,
                    'title' => (string) ($row->title ?: 'Untitled'),
                    'author_id' => $row->author_id ? (int) $row->author_id : null,
                    'author_name' => (string) ($row->author_name ?: 'Unknown Author'),
                    'cover_url' => (string) ($row->cover_url ?: ''),
                    'file_url' => (string) ($row->file_url ?: ''),
                    'category_id' => $row->category_id ? (int) $row->category_id : null,
                    'category_name' => (string) ($row->category_name ?: 'Uncategorized'),
                    'title_match_score' => $titleMatchScore,
                    'same_category_score' => $sameCategoryScore,
                    'base_tag_match_count' => $baseTagMatchCount,
                    'base_tag_score' => $baseTagScore,
                    'favorite_score' => $favoriteScore,
                    'final_score' => $finalScore,
                    'created_at' => $row->created_at,
                    'updated_at' => $row->updated_at,
                    'tags' => $this->mapTagsForBook((int) $row->id, $tagsByBook),
                ];
            })
            ->filter(function ($row) {
                return
                    (int) $row['title_match_score'] > 0 ||
                    (int) $row['same_category_score'] > 0 ||
                    (int) $row['base_tag_match_count'] > 0;
            })
            ->sort(function ($a, $b) {
                if ((int) $b['title_match_score'] !== (int) $a['title_match_score']) {
                    return (int) $b['title_match_score'] <=> (int) $a['title_match_score'];
                }

                if ((int) $b['base_tag_match_count'] !== (int) $a['base_tag_match_count']) {
                    return (int) $b['base_tag_match_count'] <=> (int) $a['base_tag_match_count'];
                }

                if ((int) $b['same_category_score'] !== (int) $a['same_category_score']) {
                    return (int) $b['same_category_score'] <=> (int) $a['same_category_score'];
                }

                if ((int) $b['favorite_score'] !== (int) $a['favorite_score']) {
                    return (int) $b['favorite_score'] <=> (int) $a['favorite_score'];
                }

                if ((int) $b['final_score'] !== (int) $a['final_score']) {
                    return (int) $b['final_score'] <=> (int) $a['final_score'];
                }

                return strcasecmp((string) $a['title'], (string) $b['title']);
            })
            ->take($limit)
            ->values();

        return response()->json([
            'data' => $data,
            'base_book' => [
                'id' => (int) $baseBook->id,
                'title' => (string) $baseBook->title,
            ],
        ]);
    }

    protected function getReadProgressPercentMap(int $userId): Collection
    {
        if ($userId <= 0) {
            return collect();
        }

        return DB::table('pdf_read_progress')
            ->where('user_id', $userId)
            ->whereNotNull('item_id')
            ->select([
                'item_id',
                DB::raw('MAX(
                    CASE
                        WHEN percent IS NOT NULL THEN percent
                        WHEN total_pages IS NOT NULL AND total_pages > 0
                            THEN ROUND((LEAST(last_page, total_pages) / total_pages) * 100, 2)
                        ELSE 0
                    END
                ) as progress_percent'),
            ])
            ->groupBy('item_id')
            ->pluck('progress_percent', 'item_id')
            ->mapWithKeys(fn ($percent, $itemId) => [(int) $itemId => (float) $percent]);
    }

    private function resolveLimit(Request $request, int $default = self::DEFAULT_LIMIT): int
    {
        return max(1, min((int) $request->input('limit', $default), self::MAX_LIMIT));
    }

    private function getBaseBookRows(): Collection
    {
        return DB::table('items')
            ->leftJoin('categories', 'items.category_id', '=', 'categories.id')
            ->leftJoin('users as authors', 'items.author_id', '=', 'authors.id')
            ->leftJoin('book_views as bv', 'items.id', '=', 'bv.book_id')
            ->groupBy([
                'items.id',
                'items.title',
                'items.author_id',
                'items.cover_url',
                'items.file_url',
                'items.category_id',
                'items.created_at',
                'items.updated_at',
                'categories.name',
                'authors.name',
            ])
            ->select([
                'items.id',
                'items.title',
                'items.author_id',
                'items.cover_url',
                'items.file_url',
                'items.category_id',
                'items.created_at',
                'items.updated_at',
                DB::raw('COALESCE(categories.name, "Uncategorized") as category_name'),
                DB::raw('COALESCE(authors.name, "Unknown Author") as author_name'),
                DB::raw('COUNT(bv.id) as views_count'),
            ])
            ->get();
    }

    private function getFavoriteIdSet(int $userId): array
    {
        if ($userId <= 0) {
            return [];
        }

        $favoriteBookIds = DB::table('user_favorite_books')
            ->where('user_id', $userId)
            ->pluck('book_id')
            ->map(fn ($id) => (int) $id)
            ->all();

        return array_flip($favoriteBookIds);
    }

    private function getTagsByBookIds(array $bookIds): Collection
    {
        if (empty($bookIds)) {
            return collect();
        }

        return DB::table('book_tag as bt')
            ->join('tags', 'bt.tag_id', '=', 'tags.id')
            ->whereIn('bt.book_id', $bookIds)
            ->select('bt.book_id', 'tags.id', 'tags.name')
            ->orderBy('tags.name')
            ->get()
            ->groupBy('book_id');
    }

    private function getUserInterestScoreMap(int $userId): Collection
    {
        if ($userId <= 0) {
            return collect();
        }

        $manualTags = DB::table('user_tag_interests')
            ->where('user_id', $userId)
            ->select([
                'tag_id',
                DB::raw((int) self::USER_INTEREST_BASE_SCORE . ' as total_score'),
            ]);

        $favoriteTags = DB::table('user_favorite_books as ufb')
            ->join('book_tag as bt', 'ufb.book_id', '=', 'bt.book_id')
            ->where('ufb.user_id', $userId)
            ->groupBy('bt.tag_id')
            ->select([
                'bt.tag_id',
                DB::raw('COUNT(*) * ' . (int) self::FAVORITE_TAG_SCORE_MULTIPLIER . ' as total_score'),
            ]);

        $viewedTags = DB::table('book_views as bv')
            ->join('book_tag as bt', 'bv.book_id', '=', 'bt.book_id')
            ->where('bv.user_id', $userId)
            ->groupBy('bt.tag_id')
            ->select([
                'bt.tag_id',
                DB::raw('COUNT(*) * ' . (int) self::VIEWED_TAG_SCORE_MULTIPLIER . ' as total_score'),
            ]);

        return DB::query()
            ->fromSub(
                $manualTags
                    ->unionAll($favoriteTags)
                    ->unionAll($viewedTags),
                'tag_scores'
            )
            ->groupBy('tag_id')
            ->select([
                'tag_id',
                DB::raw('SUM(total_score) as total_score'),
            ])
            ->pluck('total_score', 'tag_id')
            ->mapWithKeys(fn ($score, $tagId) => [(int) $tagId => (int) $score]);
    }

    private function calculateTagMatchMetrics(array $tagIds, Collection $userInterestScores): array
    {
        $matchedTagScore = 0;
        $matchedTagCount = 0;

        foreach ($tagIds as $tagId) {
            $score = (int) ($userInterestScores[$tagId] ?? 0);
            if ($score > 0) {
                $matchedTagCount++;
                $matchedTagScore += $score;
            }
        }

        return [$matchedTagScore, $matchedTagCount];
    }

    private function getBookTagIds(int $bookId, Collection $tagsByBook): array
    {
        return collect($tagsByBook[$bookId] ?? [])
            ->pluck('id')
            ->map(fn ($tagId) => (int) $tagId)
            ->filter()
            ->unique()
            ->values()
            ->all();
    }

    private function mapTagsForBook(int $bookId, Collection $tagsByBook): array
    {
        return collect($tagsByBook[$bookId] ?? [])
            ->map(function ($tag) {
                return [
                    'id' => (int) $tag->id,
                    'name' => (string) $tag->name,
                ];
            })
            ->values()
            ->all();
    }

    private function mapBookRow(object $row, Collection $tagsByBook): array
    {
        return [
            'id' => (int) $row->id,
            'title' => (string) ($row->title ?: 'Untitled'),
            'author_id' => $row->author_id ? (int) $row->author_id : null,
            'author_name' => (string) ($row->author_name ?: 'Unknown Author'),
            'cover_url' => (string) ($row->cover_url ?: ''),
            'file_url' => (string) ($row->file_url ?: ''),
            'category_id' => $row->category_id ? (int) $row->category_id : null,
            'category_name' => (string) ($row->category_name ?: 'Uncategorized'),
            'created_at' => $row->created_at,
            'updated_at' => $row->updated_at,
            'tags' => $this->mapTagsForBook((int) $row->id, $tagsByBook),
        ];
    }

    private function resolveReadProgressScore(float $readProgressPercent): int
    {
        if ($readProgressPercent >= 100) {
            return -20;
        }

        if ($readProgressPercent >= 80) {
            return 10;
        }

        if ($readProgressPercent > 0) {
            return 20;
        }

        return 0;
    }

    private function resolveRecencyScore($updatedAt): int
    {
        if (empty($updatedAt)) {
            return 0;
        }

        try {
            $daysSinceUpdate = Carbon::parse($updatedAt)->diffInDays(now());

            return match (true) {
                $daysSinceUpdate <= 7 => 10,
                $daysSinceUpdate <= 30 => 6,
                $daysSinceUpdate <= 90 => 3,
                default => 0,
            };
        } catch (\Throwable $e) {
            return 0;
        }
    }

    public function getUsers(Request $request)
    {
        $search = $request->get('search');
        $perPage = (int)$request->get('per_page', 10);

        $users = User::query()
            ->when($search, function ($query, $search) {
                $query->where(function ($query) use ($search) {
                    $query->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%")
                        ->orWhere('level', 'like', "%{$search}%");
                });
            })
            ->where('id', '<>', 1)
            ->where('id', '<>', auth()->id())
            ->orderByDesc('id')
            ->paginate($perPage);

        return response([
            'users' => UserResource::collection($users),
            'meta' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ], 200);
    }

    public function getDetailUsers(Request $request)
    {
        $search = $request->get('search');
        $perPage = (int)$request->get('per_page', 15);

        $users = User::query()
            ->when($search, function ($query, $search) {
                $query->where(function ($query) use ($search) {
                    $query->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%")
                        ->orWhere('level', 'like', "%{$search}%");
                });
            })
            ->where('id', '<>', 1)
            ->orderByDesc('id')
            ->paginate($perPage);

        return response([
            'data' => DetailUserResource::collection($users),
            'meta' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
                'from' => $users->firstItem(),
                'to' => $users->lastItem(),
            ],
        ], 200);
    }

    public function readDetailUser(Request $request, $id)
    {
        $targetUser = User::findOrFail($id);

        return response([
            'user' => new DetailUserResource($targetUser),
        ], 200);
    }

    public function createUser(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:50',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6|max:10',
            'level' => 'required|in:admin,author,user',
        ]);

        try {
            DB::beginTransaction();

            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'email_verified_at' => now(),
                'level' => $request->level,
            ]);

            $this->syncDefaultPermissionsByLevel($user);

            DB::commit();

            return response([
                'message' => 'User created.',
                'user' => new DetailUserResource($user->fresh()),
            ], 201);
        } catch (Exception $e) {
            DB::rollBack();

            return response([
                'message' => 'Failed to create user',
            ], 500);
        }
    }

    protected function syncDefaultPermissionsByLevel(User $user): void
    {
        $defaultPermissions = match ($user->level) {
            'author' => [1, 2, 3, 4, 5, 12],
            'user'   => [1, 2, 3, 4, 12],
            'admin'  => [1, 2, 3, 4, 5, 12], // adjust if admin should get all
        };

        DB::table('user_permissions')->where('user_id', $user->id)->delete();

        $rows = collect($defaultPermissions)->map(fn ($permissionId) => [
            'user_id' => $user->id,
            'permission_id' => $permissionId,
        ])->all();

        DB::table('user_permissions')->insert($rows);
    }

    public function updateUser(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:50',
            'email' => 'required|email|unique:users,email,' . $id,
            'password' => 'nullable|string|min:6|max:10',
            'level' => 'required|in:admin,author,user',
            'about_me' => ['nullable', 'string', 'max:2000'],
            'interests' => ['nullable', 'array'],
            'interests.*' => ['string', 'max:50'],
        ]);

        $authUser = $request->user();
        $targetUser = User::findOrFail($id);

        try {
            DB::beginTransaction();

            $data = [
                'name' => $request->name,
                'email' => $request->email,
                'about_me' => $request->about_me,
            ];

            // ✅ Only allow level change if NOT editing self
            if ((int)$authUser->id !== (int)$targetUser->id) {
                $data['level'] = $request->level;
            }

            // ✅ FIX: Only update password if NOT empty
            if ($request->filled('password') && trim($request->password) !== '') {
                $data['password'] = Hash::make($request->password);
            }

            // ✅ FIX: Safe interests handling
            if ($request->has('interests')) {
                $data['interests'] = $request->interests
                    ? json_encode($request->interests)
                    : null;
            }

            $targetUser->fill($data);

            // ✅ FIX: Only logout user if password changed
            if (isset($data['password'])) {
                $targetUser->tokens()->delete();
            }

            $targetUser->save();

            DB::commit();

            return response([
                'message' => 'User updated successfully.',
                'user' => new DetailUserResource($targetUser->fresh()),
            ], 200);

        } catch (\Throwable $e) {
            DB::rollBack();

            return response([
                'message' => 'Failed to update user',
                'error' => $e->getMessage(), // helpful for debug
            ], 500);
        }
    }

    public function deleteUser(Request $request, $id)
    {
        $authUser = $request->user();
        $targetUser = User::findOrFail($id);

        if ((int)$authUser->id === (int)$targetUser->id) {
            return response([
                'message' => 'You cannot delete your own account.',
            ], 422);
        }

        try {
            DB::beginTransaction();

            $targetUser->tokens()->delete();
            $targetUser->delete();

            DB::commit();

            return response([
                'message' => 'User deleted.',
            ], 200);
        } catch (Exception $e) {
            DB::rollBack();

            return response([
                'message' => 'Failed to delete user',
            ], 500);
        }
    }

    public function index(Request $request)
    {
        $search = trim((string) $request->get('search', ''));

        $query = User::query()
            ->select('id', 'name', 'email', 'level','photo','about_me','interests')
            ->orderBy('name');

        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%");
            });
        }

        return response()->json($query->limit(20)->get());
    }

    public function profile(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated.',
            ], 401);
        }

        $user->load('interestTags:id,name');

        return response()->json([
            'user' => $this->transformUser($user),
            'favorites' => $this->getFavorites($user->id),
            'device_logs' => $this->getLogs($request),
        ]);
    }

    protected function transformUser($user): array
    {
        $interestTags = $user->relationLoaded('interestTags')
            ? $user->interestTags
            : $user->interestTags()->select('tags.id', 'tags.name')->get();

        return [
            'id' => (int) $user->id,
            'name' => (string) ($user->name ?? ''),
            'email' => (string) ($user->email ?? ''),
            'photo' => $user->photo,
            'level' => (string) ($user->level ?? ''),
            'about_me' => $user->about_me,
            'interests' => $interestTags
                ->map(fn ($tag) => [
                    'id' => (int) $tag->id,
                    'name' => (string) ($tag->name ?? ''),
                ])
                ->values()
                ->all(),
        ];
    }

    protected function getFavorites(int $userId): array
    {
        $items = Item::query()
            ->with([
                'author:id,name', // 👈 IMPORTANT
                'tags:id,name',
            ])
            ->select([
                'items.id',
                'items.title',
                'items.author_id',
                'items.cover_url',
                'items.created_at',
            ])
            ->whereIn('items.id', function ($query) use ($userId) {
                $query->select('book_id')
                    ->from('user_favorite_books')
                    ->where('user_id', $userId);
            })
            ->latest('items.id')
            ->get();

        return $items->map(function ($item) {
            $authorName = $item->author?->name;

            // 🔥 fallback: fetch directly if relation failed
            if (!$authorName && $item->author_id) {
                $authorName = \App\Models\User::where('id', $item->author_id)->value('name');
            }

            return [
                'id' => (int) $item->id,
                'title' => (string) ($item->title ?: 'Untitled'),

                // ✅ always from users table
                'author' => $authorName ?: 'Unknown Author',

                'image' => $this->resolveItemImage($item->cover_url),

                'tags' => $item->tags
                    ->pluck('name')
                    ->filter()
                    ->values()
                    ->all(),
            ];
        })->values()->all();
    }

    protected function getLogs(Request $request): array
    {
        $user = $request->user();

        if (!$user) return [];

        $currentSessionId = null;

        if ($request->hasSession()) {
            try {
                $currentSessionId = $request->session()->getId();
            } catch (\Throwable $e) {
                $currentSessionId = null;
            }
        }

        if (!DB::getSchemaBuilder()->hasTable('sessions')) {
            return [];
        }

        return DB::table('sessions')
            ->select([
                'id',
                'ip_address',
                'user_agent',
                'last_activity',
            ])
            ->where('user_id', $user->id)
            ->orderByDesc('last_activity')
            ->limit(5) // ✅ add this line
            ->get()
            ->map(function ($row) use ($currentSessionId) {
                $ua = $this->parseUserAgent((string) ($row->user_agent ?? ''));

                $lastActivity = is_numeric($row->last_activity)
                    ? Carbon::createFromTimestamp((int) $row->last_activity)
                    : null;

                return [
                    'id' => 'session_' . $row->id,
                    'device' => $ua['device'],
                    'browser' => $ua['browser'],
                    'ip' => $row->ip_address ?: '-',
                    'last_active' => $this->formatActivityTime($lastActivity),

                    // ❌ removed: current / status
                ];
            })
            ->values()
            ->all();
    }

    protected function resolveItemImage(?string $image): string
    {
        if (!$image) {
            return asset('images/default-cover.png');
        }

        if (Str::startsWith($image, ['http://', 'https://', 'data:', 'blob:'])) {
            return $image;
        }

        $path = ltrim($image, '/');

        if (Str::startsWith($path, 'storage/')) {
            return asset($path);
        }

        return asset('storage/' . $path);
    }

    protected function parseUserAgent(string $userAgent): array
    {
        $ua = strtolower($userAgent);

        $browser = 'Unknown Browser';
        if (str_contains($ua, 'edg/')) {
            $browser = 'Microsoft Edge';
        } elseif (str_contains($ua, 'opr/') || str_contains($ua, 'opera')) {
            $browser = 'Opera';
        } elseif (str_contains($ua, 'chrome/') && !str_contains($ua, 'edg/')) {
            $browser = 'Chrome';
        } elseif (str_contains($ua, 'firefox/')) {
            $browser = 'Firefox';
        } elseif (str_contains($ua, 'safari/') && !str_contains($ua, 'chrome/')) {
            $browser = 'Safari';
        }

        $device = 'Desktop';
        if (str_contains($ua, 'iphone')) {
            $device = 'iPhone';
        } elseif (str_contains($ua, 'ipad')) {
            $device = 'iPad';
        } elseif (str_contains($ua, 'android')) {
            $device = str_contains($ua, 'mobile') ? 'Android Phone' : 'Android Tablet';
        } elseif (str_contains($ua, 'macintosh') || str_contains($ua, 'mac os')) {
            $device = 'Mac';
        } elseif (str_contains($ua, 'windows')) {
            $device = 'Windows PC';
        } elseif (str_contains($ua, 'linux')) {
            $device = 'Linux PC';
        }

        return [
            'device' => $device,
            'browser' => $browser,
        ];
    }

    protected function formatActivityTime(?Carbon $dateTime): string
    {
        return $dateTime ? $dateTime->diffForHumans() : '-';
    }

    public function favorites(Request $request)
    {
        return response()->json([
            'favorites' => $this->getFavorites($request->user()->id),
        ]);
    }

    public function logs(Request $request)
    {
        return response()->json([
            'device_logs' => $this->getLogs($request),
        ]);
    }

    public function interests()
    {
        $tags = Tag::query()
            ->select('id', 'name')
            ->orderBy('name')
            ->get()
            ->map(fn ($tag) => [
                'id' => (int) $tag->id,
                'name' => (string) $tag->name,
            ])
            ->values();

        return response()->json([
            'interests' => $tags,
        ]);
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function updateProfile(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);

        $user = $request->user();
        $newName = trim((string) $validated['name']);

        $user->update([
            'name' => $newName,
        ]);

        return response()->json([
//            'message' => 'Profile information updated successfully.',
            'user' => $this->transformUser($user->fresh(['interestTags:id,name'])),
        ]);
    }

    public function updateAbout(Request $request)
    {
        $validated = $request->validate([
            'about_me' => ['nullable', 'string', 'max:2000'],
            'interests' => ['nullable', 'array'],
            'interests.*' => ['integer', 'exists:tags,id'],
        ]);

        $user = $request->user();

        $aboutMe = array_key_exists('about_me', $validated)
            ? trim((string) $validated['about_me'])
            : null;

        $interestIds = collect($validated['interests'] ?? [])
            ->filter(fn ($id) => !is_null($id) && $id !== '')
            ->map(fn ($id) => (int) $id)
            ->filter(fn ($id) => $id > 0)
            ->unique()
            ->values()
            ->all();

        DB::transaction(function () use ($user, $aboutMe, $interestIds) {
            $user->update([
                'about_me' => $aboutMe !== '' ? $aboutMe : null,
            ]);

            $user->interestTags()->sync($interestIds);
        });

        $freshUser = $user->fresh(['interestTags:id,name']);

        return response()->json([
//            'message' => 'About me updated successfully.',
            'user' => $this->transformUser($freshUser),
        ]);
    }


}
