<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CategoryController extends Controller
{
    protected function makeUnicodeSlug(string $name): string
    {
        // Replace any sequence of non-letter/number with a dash
        $slug = preg_replace('/[^\p{L}\p{N}]+/u', '-', $name);
        // Collapse multiple dashes
        $slug = preg_replace('/-+/', '-', $slug);
        // Trim dashes
        $slug = trim($slug, '-');

        // Lowercase (safe for Latin, no effect on Khmer)
        return mb_strtolower($slug, 'UTF-8');
    }

    public function index()
    {
        return Category::orderBy('name')->get();

    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name'        => 'required|string|max:255|unique:categories,name',
            'slug'        => 'nullable|string|max:255|unique:categories,slug',
            'description' => 'nullable|string',
            'is_active'   => 'boolean',
        ]);

        // if frontend did not send slug or it's empty, generate it
        if (empty($data['slug'])) {
            $data['slug'] = $this->makeUnicodeSlug($data['name']);
        }

        $category = Category::create($data);

        return response()->json($category, 201);
    }

    public function update(Request $request, Category $category)
    {
        $data = $request->validate([
            'name'        => 'required|string|max:255|unique:categories,name,' . $category->id,
            'slug'        => 'nullable|string|max:255|unique:categories,slug,' . $category->id,
            'description' => 'nullable|string',
            'is_active'   => 'boolean',
        ]);

        // if slug missing, regenerate from name
        if (empty($data['slug']) && isset($data['name'])) {
            $data['slug'] = $this->makeUnicodeSlug($data['name']);
        }

        $category->update($data);

//        return response()->json($category);
        return response()->json([
            'message' => trans('message.updated_success'),
            'category' => $category
        ], 200);
    }

    public function destroy(Category $category)
    {
        $category->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
