<?php

use App\Features\Assistant\Http\Controllers\Api\AssistantController;
use Illuminate\Support\Facades\Route;

Route::post('assistant', [AssistantController::class, 'store'])->middleware('throttle:30,1');
