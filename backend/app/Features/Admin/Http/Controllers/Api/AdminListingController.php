<?php

namespace App\Features\Admin\Http\Controllers\Api;

use App\Features\Listings\Http\Resources\ListingResource;
use App\Features\Listings\Models\Listing;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class AdminListingController extends Controller
{
    public function index(Request $request)
    {
        abort_unless($request->user()->isAdmin(), 403);

        $rows = Listing::query()
            ->with(['company.industry', 'company.category', 'company.financials', 'media'])
            ->when($request->filled('status'), fn ($query) => $query->where('status', strtolower($request->string('status'))))
            ->latest()
            ->paginate(20);

        return ApiResponse::success(
            ListingResource::collection($rows->items()),
            'Listings retrieved successfully.',
            meta: [
                'current_page' => $rows->currentPage(),
                'per_page' => $rows->perPage(),
                'total' => $rows->total(),
                'last_page' => $rows->lastPage(),
            ],
        );
    }
}
