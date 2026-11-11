<?php

namespace App\Features\Registry\Http\Controllers\Api;

use App\Features\Core\Services\AuditLogger;
use App\Features\Registry\Enums\RegistrySubmissionStatus;
use App\Features\Registry\Http\Requests\StoreRegistrySubmissionRequest;
use App\Features\Registry\Http\Resources\RegistrySubmissionResource;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;

class RegistrySubmissionController extends Controller
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function index()
    {
        $rows = request()->user()
            ->registrySubmissions()
            ->with('user')
            ->latest()
            ->get();

        return ApiResponse::success(
            RegistrySubmissionResource::collection($rows),
            'Registry submissions retrieved successfully.',
        );
    }

    public function store(StoreRegistrySubmissionRequest $request)
    {
        $submission = $request->user()->registrySubmissions()->create([
            ...$request->validated(),
            'status' => RegistrySubmissionStatus::Unverified,
        ])->load('user');

        $this->audit->log('registry.submitted', $submission, $request->user(), [
            'company_name' => $submission->company_name,
        ]);

        return ApiResponse::success(
            new RegistrySubmissionResource($submission),
            'Company submitted successfully. Status is unverified.',
            201,
        );
    }
}
