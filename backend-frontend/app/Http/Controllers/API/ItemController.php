<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Item;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ItemController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $userLevel = strtolower((string) ($user->level ?? ''));
        $isAdmin = $user && ((int) $user->id === 1 || $userLevel === 'admin');
        $isAuthor = $user && $userLevel === 'author';
        $isUser = $user && $userLevel === 'user';

        $perPage = (int) $request->input('per_page', 12);
        $perPage = $perPage > 0 ? min($perPage, 100) : 12;

        $search = trim((string) $request->input('search', ''));
        $filter = strtolower(trim((string) $request->input('filter', 'all')));
        $categoryId = $request->filled('category_id');

        $query = Item::query()
            ->with([
                'category:id,name',
                'author:id,name,email',
                'tags:id,name',
            ])
            ->withCount('views')
            ->select('items.*');

        if ($isAdmin) {
            // admin can see all
        } elseif ($isAuthor) {
            $query->where('items.author_id', $user->id);
        } elseif ($isUser) {
            $query->where('items.status', 1);
        } else {
            $query->whereRaw('1 = 0');
        }

        if (!empty($categoryId)) {
            // always apply category filter
            $categoryId = $request->filled('category_id')
                ? (int) $request->input('category_id')
                : 19;
            $query->where('items.category_id', $categoryId);
        }

        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('items.title', 'like', "%{$search}%")
                    ->orWhere('items.slug', 'like', "%{$search}%")
                    ->orWhereHas('author', function ($authorQ) use ($search) {
                        $authorQ->where('name', 'like', "%{$search}%")
                            ->orWhere('email', 'like', "%{$search}%");
                    })
                    ->orWhereHas('tags', function ($tagQ) use ($search) {
                        $tagQ->where('name', 'like', "%{$search}%");
                    });
            });
        }



        if ($filter === 'favorite') {
            if ($user) {
                $query->whereIn('items.id', function ($sub) use ($user) {
                    $sub->select('book_id')
                        ->from('user_favorite_books')
                        ->where('user_id', $user->id);
                });
            } else {
                $query->whereRaw('1 = 0');
            }
        }

        if ($filter === 'new_release_section') {
            $query->where('items.updated_at', '>=', now()->subDays(7))
                ->orderByDesc('items.updated_at')
                ->orderByDesc('items.id');
        } elseif ($filter === 'popular_section') {
            $query->withCount('views')
                ->orderByDesc('views_count')
                ->orderByDesc('items.updated_at')
                ->orderByDesc('items.id');
        } elseif ($filter === 'popular') {
            $query->withCount('views')
                ->orderByDesc('views_count')
                ->orderByDesc('items.updated_at')
                ->orderByDesc('items.id');
        } elseif ($filter === 'new') {
            $query->where('items.updated_at', '>=', now()->subDays(7))
                ->orderByDesc('items.updated_at')
                ->orderByDesc('items.id');
        }else {
            $query->latest('items.id');
        }

        $items = $query->paginate($perPage);

        $items->getCollection()->transform(function ($book) {
            $book->cover_url = $book->cover_url
                ? asset('storage/' . ltrim(
                        str_replace(['storage/', '/storage/'], '', $book->cover_url),
                        '/'
                    ))
                : null;

            $book->file_url = $book->file_url
                ? asset('storage/' . ltrim(
                        str_replace(['storage/', '/storage/'], '', $book->file_url),
                        '/'
                    ))
                : null;

            $book->total_read = (int) ($book->views_count ?? 0);

            return $book;
        });

        return response()->json($items);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:255', 'unique:items,slug'],
            'description' => ['nullable', 'string'],
            'category_id' => ['required', 'exists:categories,id'],
            'author_id' => ['nullable', 'exists:users,id'],
            'publish_year' => ['nullable', 'integer', 'min:1000', 'max:' . date('Y')],
            'pages' => ['nullable', 'integer', 'min:1'],
            'language' => ['nullable', 'string', 'max:10'],
            'is_active' => ['nullable', 'boolean'],
            'tag_ids' => ['nullable', 'array'],
            'tag_ids.*' => ['integer', 'exists:tags,id'],
            'cover_url' => ['nullable', 'image', 'max:5120'],
            'file_url' => ['nullable', 'file', 'mimes:pdf,epub', 'max:52224'],
        ]);

        $book = new Item();
        $book->title = $validated['title'];
        $book->slug = !empty($validated['slug']) ? $validated['slug'] : Str::slug($validated['title']);
        $book->description = $validated['description'] ?? null;
        $book->category_id = $validated['category_id'];
        $book->author_id = $validated['author_id'] ?? null;
        $book->publish_year = $validated['publish_year'] ?? null;
        $book->pages = $validated['pages'] ?? null;
        $book->language = $validated['language'] ?? null;
        $book->is_active = (bool) ($validated['is_active'] ?? true);
        $book->user_id_created = Auth::id();



        if ($request->hasFile('cover')) {
            $book->cover_url = $request->file('cover')->store('covers', 'public');
        }

        if ($request->hasFile('file')) {
            $book->file_url = $request->file('file')->store('books', 'public');
        }

        $book->save();

        $this->createBookNotification('book_created', $book);

        $book->tags()->sync($validated['tag_ids'] ?? []);

        $book->load(['category', 'author', 'tags']);
        $book->cover_url = $book->cover ? asset('storage/' . $book->cover) : null;
        $book->file_url = $book->file ? asset('storage/' . $book->file) : null;

        return response()->json([
            'message' => 'Book created successfully',
            'item' => $book,
        ]);

    }

    public function update(Request $request, $id)
    {
        $book = Item::findOrFail($id);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'slug' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('items', 'slug')->ignore($book->id),
            ],
            'description' => ['nullable', 'string'],
            'category_id' => ['required', 'exists:categories,id'],
            'author_id' => ['nullable', 'exists:users,id'],
            'publish_year' => ['nullable', 'integer', 'min:1000', 'max:' . date('Y')],
            'pages' => ['nullable', 'integer', 'min:1'],
            'language' => ['nullable', 'string', 'max:10'],
            'is_active' => ['nullable', 'boolean'],
            'tag_ids' => ['nullable', 'array'],
            'tag_ids.*' => ['integer', 'exists:tags,id'],
            'cover_url' => ['nullable', 'image', 'max:5120'],
            'file_url' => ['nullable', 'file', 'mimes:pdf,epub', 'max:52224'],
        ]);

        $book->title = $validated['title'];
        $book->slug = !empty($validated['slug']) ? $validated['slug'] : Str::slug($validated['title']);
        $book->description = $validated['description'] ?? null;
        $book->category_id = $validated['category_id'];
        $book->author_id = $validated['author_id'] ?? null;
        $book->publish_year = $validated['publish_year'] ?? null;
        $book->pages = $validated['pages'] ?? null;
        $book->language = $validated['language'] ?? null;
        $book->is_active = (bool) ($validated['is_active'] ?? false);
        $book->user_id_updated = Auth::id();



        if ($request->hasFile('cover')) {
            if ($book->cover_url && Storage::disk('public')->exists($book->cover_url)) {
                Storage::disk('public')->delete($book->cover_url);
            }

            $book->cover_url = $request->file('cover')->store('covers', 'public');
        }

        if ($request->hasFile('file')) {
            if ($book->file_url && Storage::disk('public')->exists($book->file_url)) {
                Storage::disk('public')->delete($book->file_url);
            }

            $book->file_url = $request->file('file')->store('books', 'public');
        }

        $book->save();

        $this->createBookNotification('book_updated', $book);

        $book->tags()->sync($validated['tag_ids'] ?? []);

        $book->load(['category', 'author', 'tags']);
        $book->cover_url = $book->cover ? asset('storage/' . $book->cover_url) : null;
        $book->file_url = $book->file ? asset('storage/' . $book->file_url) : null;

        return response()->json([
            'message' => 'Book updated successfully',
            'item' => $book,
        ]);
    }

    public function destroy($id)
    {
        $book = Item::findOrFail($id);

        if (!empty($book->cover_url) && Storage::disk('public')->exists($book->cover_url)) {
            Storage::disk('public')->delete($book->cover_url);
        }

        if (!empty($book->file_url) && Storage::disk('public')->exists($book->file_url)) {
            Storage::disk('public')->delete($book->file_url);
        }

        // Remove tag relations
        $book->tags()->detach();

        // Delete record
        $book->delete();

        return response()->json([
            'message' => 'Book deleted successfully'
        ]);
    }

//    public function show(string $id)
//    {
//        $item = Item::with(['category:id,name', 'author:id,name'])->findOrFail($id);
//
//        $item->cover_url = $item->cover_url ? asset('storage/' . $item->cover_url) : null;
//        $item->file_url = $item->file_url ? asset('storage/' . $item->file_url) : null;
//
//        return response()->json($item);
//    }

    public function show(string $id)
    {
        $item = Item::with([
            'category:id,name',
            'author:id,name',
            'tags:id,name',
        ])->findOrFail($id);

        $item->cover_url = $item->cover_url
            ? asset('storage/' . $item->cover_url)
            : null;

        $item->file_url = $item->file_url
            ? asset('storage/' . $item->file_url)
            : null;

        return response()->json([
            'id' => $item->id,
            'title' => $item->title,
            'slug' => $item->slug,
            'description' => $item->description,
            'cover_url' => $item->cover_url,
            'file_url' => $item->file_url,
            'publish_year' => $item->publish_year,
            'pages' => $item->pages,
            'language' => $item->language,
            'view_count' => $item->view_count,
            'is_active' => $item->is_active,
            'created_at' => $item->created_at,
            'updated_at' => $item->updated_at,

            'category' => $item->category,
            'author' => $item->author,

            // ✅ book tags
            'tags' => $item->tags->map(function ($tag) {
                return [
                    'id' => $tag->id,
                    'name' => $tag->name,
                ];
            })->values(),
        ]);
    }


    private function createBookNotification(string $type, $item): void
    {
        $title = $type === 'book_created'
            ? 'New Book Added'
            : 'Book Updated';

        $message = $type === 'book_created'
            ? "New book released: {$item->title}"
            : "Book information updated: {$item->title}";

        $users = User::query()
            ->select('id')
            ->whereIn('level', ['admin', 'author', 'user'])
            ->get();

        foreach ($users as $user) {
            Notification::create([
                'user_id' => $user->id,
                'type' => $type,
                'title' => $title,
                'message' => $message,
                'item_id' => $item->id,
            ]);
        }
    }

}
