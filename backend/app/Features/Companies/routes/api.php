<?php

use App\Features\Companies\Http\Controllers\Api\SellerCompanyController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'role:seller'])->prefix('seller')->group(function (): void {
    Route::get('companies', [SellerCompanyController::class, 'index']);
    Route::post('companies', [SellerCompanyController::class, 'store']);
    Route::put('companies/{company}', [SellerCompanyController::class, 'update']);
});
