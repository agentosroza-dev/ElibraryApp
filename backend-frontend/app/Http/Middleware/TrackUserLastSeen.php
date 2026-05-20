<?php

namespace App\Http\Middleware;

use App\Services\LoginHistoryService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class TrackUserLastSeen
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $user = $request->user();
        $token = $user?->currentAccessToken();

        if ($user && $token) {
            app(LoginHistoryService::class)->updateLastSeenByToken(
                request: $request,
                userId: (int) $user->id,
                tokenId: (int) $token->id
            );
        }

        return $response;
    }
}
