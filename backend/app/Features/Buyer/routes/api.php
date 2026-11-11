<?php

use App\Features\Buyer\Http\Controllers\Api\BuyerController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'role:buyer'])->prefix('buyer')->group(function (): void {
    Route::get('favorites', [BuyerController::class, 'favorites']);
    Route::post('favorites/{listing}', [BuyerController::class, 'favorite']);
    Route::delete('favorites/{listing}', [BuyerController::class, 'unfavorite']);
    Route::get('interests', [BuyerController::class, 'interests']);
    Route::post('listings/{listing}/interest', [BuyerController::class, 'interest']);
    Route::patch('interests/{interest}/withdraw', [BuyerController::class, 'withdraw']);
    Route::post('listings/{listing}/inquiry', [BuyerController::class, 'inquiry']);
});
