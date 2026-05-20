<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckPermission
{
    public function handle($request, Closure $next)
    {
        $user = auth()->user();

        $route = $request->route()->getName();

        if (!$user->hasPermission($route)) {
            return response()->json([
                'message'=>'Unauthorized'
            ],403);
        }

        return $next($request);
    }
}

