<?php

use App\Features\Listings\Http\Controllers\Api\ListingController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth.optional')->group(function (): void {
    Route::get('listings', [ListingController::class, 'index']);
    Route::get('listings/{slug}', [ListingController::class, 'show']);
});
