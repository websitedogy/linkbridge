<?php

use App\Features\Registry\Http\Controllers\Api\RegistrySubmissionController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('registry-submissions', [RegistrySubmissionController::class, 'index']);
    Route::post('registry-submissions', [RegistrySubmissionController::class, 'store']);
});
