<?php

namespace App\Features\Auth\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class OptionalSanctum
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->bearerToken()) {
            $user = Auth::guard('sanctum')->user();

            if ($user === null) {
                abort(401, 'Unauthorized.');
            }

            Auth::setUser($user);
        }

        return $next($request);
    }
}
