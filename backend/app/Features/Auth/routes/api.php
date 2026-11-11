<?php

use App\Features\Auth\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function (): void {
    Route::post('register', [AuthController::class, 'register'])->middleware('throttle:login');
    Route::post('login', [AuthController::class, 'login'])->middleware('throttle:login');
    Route::post('verify-otp', [AuthController::class, 'verifyOtp'])->middleware('throttle:login');
    Route::post('resend-otp', [AuthController::class, 'resendOtp'])->middleware('throttle:login');
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::get('me', [AuthController::class, 'me'])->middleware('auth:sanctum');
    Route::put('profile', [AuthController::class, 'update'])->middleware('auth:sanctum');
});
