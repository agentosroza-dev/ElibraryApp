<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\BookView;
use App\Models\Item;
use Illuminate\Http\Request;

class BookViewController extends Controller
{
    public function store(Request $request, Item $book)
    {
        $user = $request->user();

        $view = BookView::create([
            'user_id' => $user?->id,
            'book_id' => $book->id,
            'created_at' => now(),
        ]);

        return response()->json([
            'message' => 'Book view recorded successfully.',
            'view' => $view,
        ]);
    }

    public function count(Item $book)
    {
        $userId = auth()->id();

        return response()->json([
            'book_id' => $book->id,

            // total views
            'views_count' => BookView::where('book_id', $book->id)->count(),

            // unique users
            'unique_users_count' => BookView::where('book_id', $book->id)
                ->whereNotNull('user_id')
                ->distinct()
                ->count('user_id'),

            // current user views
            'my_views_count' => BookView::where('book_id', $book->id)
                ->where('user_id', $userId)
                ->count(),
        ]);
    }




}
