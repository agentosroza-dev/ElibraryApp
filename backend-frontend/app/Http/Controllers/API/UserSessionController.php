<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserSessionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $currentSessionId = null;

        try {
            if ($request->hasSession()) {
                $currentSessionId = $request->session()->getId();
            }
        } catch (\Throwable $e) {
            $currentSessionId = null;
        }

        $sessions = DB::table('sessions')
            ->where('user_id', $user->id)
            ->orderByDesc('last_activity')
            ->get()
            ->map(function ($session) use ($currentSessionId) {
                return [
                    'id' => $session->id,
                    'ip_address' => $session->ip_address,
                    'user_agent' => $session->user_agent,
                    'last_activity' => $session->last_activity
                        ? \Carbon\Carbon::createFromTimestamp((int) $session->last_activity)->toDateTimeString()
                        : null,
                    'is_current' => $currentSessionId && $currentSessionId === $session->id,
                ];
            })
            ->values();

        return response()->json([
            'data' => $sessions,
        ]);
    }
}
