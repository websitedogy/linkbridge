<?php

use App\Features\Admin\Http\Controllers\Api\AdminListingController;
use App\Features\Admin\Http\Controllers\Api\AdminRegistrySubmissionController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'role:admin|super_admin'])->prefix('admin')->group(function (): void {
    Route::get('listings', [AdminListingController::class, 'index']);
    Route::get('registry-submissions', [AdminRegistrySubmissionController::class, 'index']);
});
