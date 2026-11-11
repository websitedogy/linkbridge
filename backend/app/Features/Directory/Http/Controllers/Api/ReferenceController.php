<?php

namespace App\Features\Directory\Http\Controllers\Api;

use App\Features\Directory\Models\Category;
use App\Features\Directory\Models\Industry;
use App\Features\Directory\Models\Location;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class ReferenceController extends Controller
{
    public function industries()
    {
        $rows = Industry::query()->where('is_active', true)->orderBy('name')->get(['id', 'name', 'slug']);

        return ApiResponse::success($rows, 'Industries retrieved successfully.');
    }

    public function categories(Request $request)
    {
        $rows = Category::query()
            ->where('is_active', true)
            ->when($request->string('industry')->isNotEmpty(), function ($query) use ($request) {
                $query->whereHas('industry', fn ($industry) => $industry->where('slug', $request->string('industry')));
            })
            ->orderBy('name')
            ->get(['id', 'industry_id', 'name', 'slug']);

        return ApiResponse::success($rows, 'Categories retrieved successfully.');
    }

    public function locations(Request $request)
    {
        $rows = Location::query()
            ->where('is_active', true)
            ->when($request->filled('type'), fn ($query) => $query->where('type', $request->string('type')))
            ->when($request->filled('parent_id'), fn ($query) => $query->where('parent_id', $request->string('parent_id')))
            ->orderBy('name')
            ->get(['id', 'parent_id', 'type', 'name', 'slug', 'country_code']);

        return ApiResponse::success($rows, 'Locations retrieved successfully.');
    }
}
