<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Item;
use App\Models\Tag;
use Illuminate\Http\Request;

class BookTagController extends Controller
{
    public function index($bookId)
    {
        $book = Item::with('tags')->findOrFail($bookId);

        return response()->json([
            'book_id' => $book->id,
            'tags' => $book->tags->map(function ($tag) {
                return [
                    'id' => $tag->id,
                    'name' => $tag->name,
                    'slug' => $tag->slug,
                    'pivot' => [
                        'book_id' => $tag->pivot->book_id,
                        'tag_id' => $tag->pivot->tag_id,
                        'created_at' => $tag->pivot->created_at,
                        'updated_at' => $tag->pivot->updated_at,
                    ],
                ];
            }),
        ]);
    }

    public function update(Request $request, Item $book)
    {
        $validated = $request->validate([
            'tag_ids' => ['nullable', 'array'],
            'tag_ids.*' => ['integer', 'exists:tags,id'],
        ]);

        $tagIds = $validated['tag_ids'] ?? [];

        $book->tags()->sync($tagIds);

        return response()->json([
            'message' => 'Book tags updated successfully.',
            'tags' => $book->tags()->get(),
        ]);
    }

    public function attach(Request $request, Item $book)
    {
        $validated = $request->validate([
            'tag_id' => ['required', 'integer', 'exists:tags,id'],
        ]);

        $book->tags()->syncWithoutDetaching([$validated['tag_id']]);

        return response()->json([
            'message' => 'Tag attached successfully.',
            'tags' => $book->tags()->get(),
        ]);
    }

    public function detach(Item $book, Tag $tag)
    {
        $book->tags()->detach($tag->id);

        return response()->json([
            'message' => 'Tag detached successfully.',
            'tags' => $book->tags()->get(),
        ]);
    }
}
