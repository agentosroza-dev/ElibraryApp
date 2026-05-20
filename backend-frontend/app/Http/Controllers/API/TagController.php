<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Tag;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class TagController extends Controller
{
    public function index(Request $request)
    {
        $search = trim((string) $request->get('search', ''));

        $query = Tag::query();

        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('slug', 'like', "%{$search}%");
            });
        }

        $tags = $query->latest()->get();

        return response()->json($tags);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:255', 'unique:tags,slug'],
        ]);

        $slug = $validated['slug'] ?? Str::slug($validated['name']);

        if (!$slug) {
            $slug = Str::lower(Str::random(8));
        }

        $originalSlug = $slug;
        $counter = 1;

        while (Tag::where('slug', $slug)->exists()) {
            $slug = $originalSlug . '-' . $counter++;
        }

        $tag = Tag::create([
            'name' => $validated['name'],
            'slug' => $slug,
        ]);

        return response()->json([
            'message' => 'Tag created successfully',
            'data' => $tag,
        ], 201);
    }

    public function show(string $id)
    {
        $tag = Tag::findOrFail($id);

        return response()->json($tag);
    }

    public function update(Request $request, string $id)
    {
        $tag = Tag::findOrFail($id);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'slug' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('tags', 'slug')->ignore($tag->id),
            ],
        ]);

        $slug = $validated['slug'] ?? Str::slug($validated['name']);

        if (!$slug) {
            $slug = Str::lower(Str::random(8));
        }

        $originalSlug = $slug;
        $counter = 1;

        while (
        Tag::where('slug', $slug)
            ->where('id', '!=', $tag->id)
            ->exists()
        ) {
            $slug = $originalSlug . '-' . $counter++;
        }

        $tag->update([
            'name' => $validated['name'],
            'slug' => $slug,
        ]);

        return response()->json([
            'message' => 'Tag updated successfully',
            'data' => $tag,
        ]);
    }

    public function destroy(string $id)
    {
        $tag = Tag::findOrFail($id);
        $tag->delete();

        return response()->json([
            'message' => 'Tag deleted successfully',
        ]);
    }
}
