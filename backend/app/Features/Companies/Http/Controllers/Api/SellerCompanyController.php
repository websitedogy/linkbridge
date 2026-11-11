<?php

namespace App\Features\Companies\Http\Controllers\Api;

use App\Features\Companies\Http\Requests\CompanyRequest;
use App\Features\Companies\Http\Resources\CompanyResource;
use App\Features\Companies\Models\Company;
use App\Features\Companies\Services\CompanyService;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;

class SellerCompanyController extends Controller
{
    public function __construct(private readonly CompanyService $companies) {}

    public function index()
    {
        $rows = request()->user()->companies()->with(['industry', 'category', 'financials'])->latest()->get();

        return ApiResponse::success(CompanyResource::collection($rows), 'Companies retrieved successfully.');
    }

    public function store(CompanyRequest $request)
    {
        $this->authorize('create', Company::class);
        $company = $this->companies->create($request->user(), $request->validated());

        return ApiResponse::success(new CompanyResource($company), 'Company created successfully.', 201);
    }

    public function update(CompanyRequest $request, Company $company)
    {
        $this->authorize('update', $company);
        $company = $this->companies->update($company, $request->validated());

        return ApiResponse::success(new CompanyResource($company), 'Company updated successfully.');
    }
}
