<?php

use App\Features\Directory\Http\Controllers\Api\ReferenceController;
use Illuminate\Support\Facades\Route;

Route::get('industries', [ReferenceController::class, 'industries']);
Route::get('categories', [ReferenceController::class, 'categories']);
Route::get('locations', [ReferenceController::class, 'locations']);
