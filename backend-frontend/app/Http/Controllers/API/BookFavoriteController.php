<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Item;
use App\Models\UserFavoriteBook;
use Illuminate\Http\Request;

class BookFavoriteController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $favorites = UserFavoriteBook::with('book')
            ->where('user_id', $user->id)
            ->latest('created_at')
            ->get();

        return response()->json([
            'favorites' => $favorites,
        ]);
    }

    public function store(Request $request, Item $book)
    {
        $user = $request->user();

        $favorite = UserFavoriteBook::firstOrCreate(
            [
                'user_id' => $user->id,
                'book_id' => $book->id,
            ],
            [
                'created_at' => now(),
            ]
        );

        return response()->json([
            'message' => 'Book added to favorites successfully.',
            'favorite' => $favorite,
            'is_favorite' => true,
        ]);
    }

    public function destroy(Request $request, Item $book)
    {
        $user = $request->user();

        UserFavoriteBook::where('user_id', $user->id)
            ->where('book_id', $book->id)
            ->delete();

        return response()->json([
            'message' => 'Book removed from favorites successfully.',
            'is_favorite' => false,
        ]);
    }

    public function check(Request $request, Item $book)
    {
        $user = $request->user();

        $isFavorite = UserFavoriteBook::where('user_id', $user->id)
            ->where('book_id', $book->id)
            ->exists();

        return response()->json([
            'is_favorite' => $isFavorite,
        ]);
    }
}
