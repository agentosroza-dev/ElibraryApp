<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\LoginHistory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Carbon\Carbon;

class LoginHistoryController extends Controller
{

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $rows = LoginHistory::query()
            ->where('user_id', $user->id)
            ->orderByDesc('login_at')
            ->limit(5)
            ->get();

        $rows = $rows->map(function ($item) {
            $loginAt = $item->login_at ? Carbon::parse($item->login_at) : null;

            return [
                ...$item->toArray(),
                'last_active' => $loginAt
                    ? $loginAt->diffForHumans(now(), [
                        'parts' => 2,
                        'short' => true
                    ])
                    : null,
            ];
        });

        return response()->json([
            'data' => $rows
        ]);
    }


    public function current(Request $request)
    {
        $user = $request->user();

        $row = $user->loginHistories()
            ->where('is_current', true)
            ->latest('login_at')
            ->first();

        return response()->json([
            'data' => $row,
        ]);
    }
}
