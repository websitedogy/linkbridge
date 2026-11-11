<?php

use App\Features\Seller\Http\Controllers\Api\SellerEngagementController;
use App\Features\Seller\Http\Controllers\Api\SellerListingController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'role:seller'])->prefix('seller')->group(function (): void {
    Route::get('listings', [SellerListingController::class, 'index']);
    Route::post('listings', [SellerListingController::class, 'store']);
    Route::get('listings/{listing}', [SellerListingController::class, 'show']);
    Route::put('listings/{listing}', [SellerListingController::class, 'update']);
    Route::delete('listings/{listing}', [SellerListingController::class, 'destroy']);
    Route::post('listings/{listing}/submit', [SellerListingController::class, 'submit']);
    Route::post('listings/{listing}/media', [SellerListingController::class, 'media']);
    Route::get('interests', [SellerEngagementController::class, 'interests']);
    Route::patch('interests/{interest}', [SellerEngagementController::class, 'updateInterest']);
    Route::get('inquiries', [SellerEngagementController::class, 'inquiries']);
});
