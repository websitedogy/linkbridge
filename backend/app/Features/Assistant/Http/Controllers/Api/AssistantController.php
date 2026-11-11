<?php

namespace App\Features\Assistant\Http\Controllers\Api;

use App\Features\Assistant\Http\Requests\AssistantRequest;
use App\Features\Assistant\Services\AssistantService;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;

class AssistantController extends Controller
{
    public function __construct(private AssistantService $assistant) {}

    public function store(AssistantRequest $request)
    {
        return ApiResponse::success(
            $this->assistant->reply($request->string('message')->toString()),
            'Reply ready.',
        );
    }
}
