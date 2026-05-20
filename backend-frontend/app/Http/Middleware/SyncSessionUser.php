<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SyncSessionUser
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        try {
            if ($request->hasSession()) {
                DB::table('sessions')
                    ->where('id', $request->session()->getId())
                    ->update([
                        'user_id' => optional($request->user())->id,
                        'ip_address' => $request->ip(),
                        'user_agent' => mb_substr((string) $request->userAgent(), 0, 500),
                        'last_activity' => now()->timestamp,
                    ]);
            }
        } catch (\Throwable $e) {
            //
        }

        return $response;
    }
}
