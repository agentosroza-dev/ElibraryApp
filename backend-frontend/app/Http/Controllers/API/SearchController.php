<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Item;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class SearchController extends Controller
{
    public function search(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = trim((string) $request->input('q', ''));
        $sort = strtolower(trim((string) $request->input('sort', 'best')));
        $perPage = (int) $request->input('per_page', 12);
        $perPage = $perPage > 0 ? min($perPage, 50) : 12;

        if ($query === '') {
            return response()->json([
                'data' => [],
                'meta' => [
                    'query' => $query,
                    'sort' => $sort,
                    'current_page' => 1,
                    'last_page' => 1,
                    'per_page' => $perPage,
                    'total' => 0,
                ],
            ]);
        }

        $normalizedQuery = mb_strtolower($query);
        $terms = $this->extractTerms($normalizedQuery);

        $items = Item::query()
            ->with([
                'category:id,name',
                'author:id,name',
                'tags:id,name',
            ])
            ->withCount('views')
            ->select('items.*')
            ->when($user, fn (Builder $q) => $this->applyVisibilityScope($q, $user))
            ->where(function (Builder $builder) use ($normalizedQuery, $terms) {
                $builder
                    ->whereRaw('LOWER(items.title) LIKE ?', ['%' . $normalizedQuery . '%'])
                    ->orWhereRaw('LOWER(COALESCE(items.description, "")) LIKE ?', ['%' . $normalizedQuery . '%'])
                    ->orWhereHas('author', function (Builder $authorQuery) use ($normalizedQuery) {
                        $authorQuery->whereRaw('LOWER(name) LIKE ?', ['%' . $normalizedQuery . '%']);
                    })
                    ->orWhereHas('category', function (Builder $categoryQuery) use ($normalizedQuery) {
                        $categoryQuery->whereRaw('LOWER(name) LIKE ?', ['%' . $normalizedQuery . '%']);
                    })
                    ->orWhereHas('tags', function (Builder $tagQuery) use ($normalizedQuery, $terms) {
                        $tagQuery->whereRaw('LOWER(name) LIKE ?', ['%' . $normalizedQuery . '%']);

                        foreach ($terms as $term) {
                            $tagQuery->orWhereRaw('LOWER(name) LIKE ?', ['%' . $term . '%']);
                        }
                    });

                foreach ($terms as $term) {
                    $builder->orWhereRaw('LOWER(items.title) LIKE ?', ['%' . $term . '%']);
                }
            })
            ->leftJoin('categories', 'categories.id', '=', 'items.category_id')
            ->leftJoin('users as authors', 'authors.id', '=', 'items.author_id')
            ->leftJoin('book_tag', 'book_tag.book_id', '=', 'items.id')
            ->leftJoin('tags', 'tags.id', '=', 'book_tag.tag_id')
            ->groupBy('items.id')
            ->selectRaw($this->buildScoreSql(), $this->buildScoreBindings($normalizedQuery, $terms))
            ->when($sort === 'popular', function (Builder $builder) {
                $builder
                    ->orderByDesc('views_count')
                    ->orderByDesc('search_score')
                    ->orderByDesc('items.created_at');
            })
            ->when($sort === 'newest', function (Builder $builder) {
                $builder
                    ->orderByDesc('items.created_at')
                    ->orderByDesc('search_score')
                    ->orderByDesc('views_count');
            })
            ->when(!in_array($sort, ['popular', 'newest'], true), function (Builder $builder) {
                $builder
                    ->orderByDesc('search_score')
                    ->orderByDesc('views_count')
                    ->orderByDesc('items.created_at');
            })
            ->paginate($perPage);

        $collection = $items->getCollection()->map(fn ($item) => $this->transformItem($item));
        $items->setCollection($collection);

        return response()->json([
            'data' => $items->items(),
            'meta' => [
                'query' => $query,
                'sort' => $sort,
                'current_page' => $items->currentPage(),
                'last_page' => $items->lastPage(),
                'per_page' => $items->perPage(),
                'total' => $items->total(),
            ],
        ]);
    }

    public function trending(Request $request): JsonResponse
    {
        $user = $request->user();

        $limit = (int) $request->input('limit', 10);
        $limit = $limit > 0 ? min($limit, 20) : 10;

        $manualInterestTags = null;

        if ($user) {
            $manualInterestTags = DB::table('user_tag_interests')
                ->where('user_id', $user->id)
                ->selectRaw('tag_id, COUNT(*) as score')
                ->groupBy('tag_id');
        }

        $viewedTags = DB::table('book_views as bv')
            ->join('book_tag as bt', 'bt.book_id', '=', 'bv.book_id')
            ->selectRaw('bt.tag_id, COUNT(*) as score')
            ->groupBy('bt.tag_id');

        $favoriteTags = DB::table('user_favorite_books as ufb')
            ->join('book_tag as bt', 'bt.book_id', '=', 'ufb.book_id')
            ->selectRaw('bt.tag_id, COUNT(*) as score')
            ->groupBy('bt.tag_id');

        $progressTags = DB::table('pdf_read_progress as pr')
            ->join('book_tag as bt', 'bt.book_id', '=', 'pr.item_id')
            ->selectRaw('bt.tag_id, COUNT(*) as score')
            ->groupBy('bt.tag_id');

        $query = DB::table('tags')
            ->leftJoinSub($viewedTags, 'v', fn ($join) => $join->on('tags.id', '=', 'v.tag_id'))
            ->leftJoinSub($favoriteTags, 'f', fn ($join) => $join->on('tags.id', '=', 'f.tag_id'))
            ->leftJoinSub($progressTags, 'p', fn ($join) => $join->on('tags.id', '=', 'p.tag_id'));

        if ($manualInterestTags) {
            $query->leftJoinSub($manualInterestTags, 'i', fn ($join) => $join->on('tags.id', '=', 'i.tag_id'));
        }

        $selectRaw = "
            tags.id,
            tags.name,
            COALESCE(v.score, 0) as total_views,
            COALESCE(f.score, 0) as total_favorites,
            COALESCE(p.score, 0) as total_progress,
            " . ($manualInterestTags ? "COALESCE(i.score, 0)" : "0") . " as total_interest,
            (
                " . ($manualInterestTags ? "(COALESCE(i.score, 0) * 4) +" : "") . "
                COALESCE(v.score, 0)
                + (COALESCE(f.score, 0) * 3)
                + (COALESCE(p.score, 0) * 2)
            ) as trending_score
        ";

        $tags = $query
            ->selectRaw($selectRaw)
            ->where(function ($builder) use ($manualInterestTags) {
                if ($manualInterestTags) {
                    $builder->whereNotNull('i.tag_id');
                }

                $builder->orWhereNotNull('v.tag_id')
                    ->orWhereNotNull('f.tag_id')
                    ->orWhereNotNull('p.tag_id');
            })
            ->orderByDesc('trending_score')
            ->limit($limit)
            ->get()
            ->map(fn ($row) => [
                'id' => (int) $row->id,
                'name' => (string) $row->name,
                'total_views' => (int) $row->total_views,
                'total_favorites' => (int) $row->total_favorites,
                'total_progress' => (int) $row->total_progress,
                'total_interest' => (int) $row->total_interest,
                'trending_score' => (float) $row->trending_score,
            ])
            ->values();

        return response()->json([
            'data' => $tags,
        ]);
    }

    public function suggested(Request $request): JsonResponse
    {
        $user = $request->user();

        $limit = (int) $request->input('limit', 8);
        $limit = $limit > 0 ? min($limit, 20) : 8;

        $tagScores = $user
            ? $this->getSuggestedTagScores((int) $user->id)
            : collect();

        $progressScoreMap = $this->getBookProgressScoreMap();
        $favoriteScoreMap = $this->getBookFavoriteScoreMap();

        $items = Item::query()
            ->with([
                'category:id,name',
                'author:id,name',
                'tags:id,name',
            ])
            ->withCount('views')
            ->select('items.*')
            ->where('items.is_active', 1)
            ->when($user, fn (Builder $query) => $this->applyVisibilityScope($query, $user))
            ->latest('items.created_at')
            ->limit(150)
            ->get()
            ->map(function (Item $item) use ($tagScores, $progressScoreMap, $favoriteScoreMap) {
                $tagInterestScore = $item->tags->sum(
                    fn ($tag) => (float) ($tagScores->get((int) $tag->id, 0))
                );

                $viewsCount = (int) ($item->views_count ?? 0);
                $favoriteCount = (int) ($favoriteScoreMap->get((int) $item->id, 0));
                $progressScore = (float) ($progressScoreMap->get((int) $item->id, 0));

                $item->suggested_score = round(
                    ($tagInterestScore * 10) +
                    (min($favoriteCount, 100) * 6) +
                    (min($viewsCount, 500) * 0.5) +
                    $progressScore,
                    2
                );

                return $item;
            })
            ->sortByDesc('suggested_score')
            ->take($limit)
            ->values()
            ->map(function (Item $item) {
                $row = $this->transformItem($item);
                $row['suggested_score'] = round((float) ($item->suggested_score ?? 0), 2);
                return $row;
            });

        return response()->json([
            'data' => $items,
        ]);
    }

    private function getSuggestedTagScores(int $userId): Collection
    {
        if ($userId <= 0) {
            return collect();
        }

        $manualTags = DB::table('user_tag_interests')
            ->where('user_id', $userId)
            ->selectRaw('tag_id, 10 as total_score');

        $viewedTags = DB::table('book_views as bv')
            ->join('book_tag as bt', 'bv.book_id', '=', 'bt.book_id')
            ->where('bv.user_id', $userId)
            ->groupBy('bt.tag_id')
            ->selectRaw('bt.tag_id, COUNT(*) * 3 as total_score');

        $favoriteTags = DB::table('user_favorite_books as ufb')
            ->join('book_tag as bt', 'ufb.book_id', '=', 'bt.book_id')
            ->where('ufb.user_id', $userId)
            ->groupBy('bt.tag_id')
            ->selectRaw('bt.tag_id, COUNT(*) * 5 as total_score');

        $progressTags = DB::table('pdf_read_progress as pr')
            ->join('book_tag as bt', 'pr.item_id', '=', 'bt.book_id')
            ->where('pr.user_id', $userId)
            ->whereNotNull('pr.item_id')
            ->groupBy('bt.tag_id')
            ->selectRaw('bt.tag_id, (COUNT(*) * 2) + (COALESCE(SUM(pr.percent), 0) * 0.05) as total_score');

        return DB::query()
            ->fromSub(
                $manualTags
                    ->unionAll($viewedTags)
                    ->unionAll($favoriteTags)
                    ->unionAll($progressTags),
                'tag_scores'
            )
            ->groupBy('tag_id')
            ->selectRaw('tag_id, SUM(total_score) as score')
            ->pluck('score', 'tag_id');
    }

    private function getBookFavoriteScoreMap(): Collection
    {
        return DB::table('user_favorite_books')
            ->selectRaw('book_id, COUNT(*) as total_favorites')
            ->groupBy('book_id')
            ->pluck('total_favorites', 'book_id');
    }

    private function getBookProgressScoreMap(): Collection
    {
        return DB::table('pdf_read_progress')
            ->whereNotNull('item_id')
            ->selectRaw('item_id, (COUNT(*) * 2) + (COALESCE(SUM(percent), 0) * 0.05) as progress_score')
            ->groupBy('item_id')
            ->pluck('progress_score', 'item_id');
    }

    protected function applyVisibilityScope(Builder $query, $user): void
    {
        $level = strtolower((string) ($user->level ?? ''));

        if ((int) $user->id === 1 || $level === 'admin') {
            return;
        }

        if ($level === 'author') {
            $query->where('items.author_id', $user->id);
            return;
        }

        $query->where('items.status', 1);
    }

    protected function extractTerms(string $query): array
    {
        return collect(preg_split('/\s+/', trim($query)))
            ->filter(fn ($value) => filled($value))
            ->map(fn ($value) => mb_strtolower(trim($value)))
            ->unique()
            ->values()
            ->all();
    }

    protected function buildScoreSql(): string
    {
        return "
            (
                CASE
                    WHEN LOWER(items.title) = ? THEN 1000
                    ELSE 0
                END
                +
                CASE
                    WHEN LOWER(items.title) LIKE ? THEN 600
                    ELSE 0
                END
                +
                CASE
                    WHEN LOWER(items.title) LIKE ? THEN 350
                    ELSE 0
                END
                +
                CASE
                    WHEN LOWER(COALESCE(authors.name, '')) LIKE ? THEN 120
                    ELSE 0
                END
                +
                CASE
                    WHEN LOWER(COALESCE(categories.name, '')) LIKE ? THEN 80
                    ELSE 0
                END
                +
                CASE
                    WHEN LOWER(COALESCE(items.description, '')) LIKE ? THEN 40
                    ELSE 0
                END
                +
                MAX(
                    CASE
                        WHEN LOWER(COALESCE(tags.name, '')) = ? THEN 320
                        WHEN LOWER(COALESCE(tags.name, '')) LIKE ? THEN 220
                        ELSE 0
                    END
                )
                +
                (
                    COALESCE((
                        SELECT COUNT(*)
                        FROM book_views bv2
                        WHERE bv2.book_id = items.id
                    ), 0) * 0.3
                )
            ) as search_score,
            COALESCE((
                SELECT COUNT(*)
                FROM book_views bv3
                WHERE bv3.book_id = items.id
            ), 0) as views_count
        ";
    }

    protected function buildScoreBindings(string $query, array $terms): array
    {
        return [
            $query,
            $query . '%',
            '%' . $query . '%',
            '%' . $query . '%',
            '%' . $query . '%',
            '%' . $query . '%',
            $query,
            '%' . $query . '%',
        ];
    }

    protected function transformItem($item): array
    {
        $cover = $item->cover_url
            ?? $item->cover
            ?? $item->thumbnail
            ?? null;

        return [
            'id' => (int) $item->id,
            'title' => (string) ($item->title ?? 'Untitled'),
            'description' => (string) ($item->description ?? ''),
            'file_url' => (string) ($item->file_url ?? ''),
            'category' => [
                'id' => (int) ($item->category->id ?? 0),
                'name' => (string) ($item->category->name ?? 'Uncategorized'),
            ],
            'author' => [
                'id' => (int) ($item->author->id ?? 0),
                'name' => (string) ($item->author->name ?? 'Unknown Author'),
            ],
            'tags' => collect($item->tags ?? [])
                ->map(fn ($tag) => [
                    'id' => (int) $tag->id,
                    'name' => (string) $tag->name,
                ])
                ->values()
                ->all(),
            'cover_url' => $this->toAssetUrl($cover),
            'views_count' => (int) ($item->views_count ?? 0),
            'search_score' => round((float) ($item->search_score ?? 0), 2),
            'created_at' => optional($item->created_at)?->toDateTimeString(),
            'status' => (int) ($item->status ?? 0),
        ];
    }

    protected function toAssetUrl(?string $path): ?string
    {
        $value = trim((string) $path);

        if ($value === '') {
            return null;
        }

        if (preg_match('/^https?:\/\//i', $value)) {
            return $value;
        }

        $value = preg_replace('#^/?storage/#i', '', $value);
        $value = preg_replace('#^/?public/#i', '', $value);
        $value = ltrim($value, '/');

        return url('storage/' . $value);
    }
}
