<?php

namespace App\Features\Admin\Http\Controllers\Api;

use App\Features\Registry\Http\Resources\RegistrySubmissionResource;
use App\Features\Registry\Models\RegistrySubmission;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class AdminRegistrySubmissionController extends Controller
{
    public function index(Request $request)
    {
        abort_unless($request->user()->isAdmin(), 403);

        $rows = RegistrySubmission::query()
            ->with('user')
            ->when($request->filled('status'), fn ($query) => $query->where('status', strtolower((string) $request->string('status'))))
            ->latest()
            ->paginate(20);

        return ApiResponse::success(
            RegistrySubmissionResource::collection($rows->items()),
            'Registry submissions retrieved successfully.',
            meta: [
                'current_page' => $rows->currentPage(),
                'per_page' => $rows->perPage(),
                'total' => $rows->total(),
                'last_page' => $rows->lastPage(),
            ],
        );
    }
}
