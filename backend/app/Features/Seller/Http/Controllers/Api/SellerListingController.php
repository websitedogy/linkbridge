<?php

namespace App\Features\Seller\Http\Controllers\Api;

use App\Features\Listings\Http\Requests\ListingRequest;
use App\Features\Listings\Http\Resources\ListingResource;
use App\Features\Listings\Models\Listing;
use App\Features\Listings\Services\ListingService;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class SellerListingController extends Controller
{
    public function __construct(private readonly ListingService $listings) {}

    public function index(Request $request)
    {
        $rows = Listing::query()
            ->where('seller_id', $request->user()->id)
            ->with(['company.industry', 'company.category', 'company.financials', 'media'])
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

    public function store(ListingRequest $request)
    {
        $this->authorize('create', Listing::class);
        $company = $request->user()->companies()->whereKey($request->validated('company_id'))->firstOrFail();
        $this->authorize('update', $company);

        $listing = $this->listings->create($request->user(), $request->validated());

        return ApiResponse::success(new ListingResource($listing), 'Listing saved as draft.', 201);
    }

    public function show(Request $request, Listing $listing)
    {
        $this->authorize('view', $listing);
        abort_unless($listing->seller_id === $request->user()->id || $request->user()->isAdmin(), 404);
        $listing->load(['company.industry', 'company.category', 'company.financials', 'media']);

        return ApiResponse::success(new ListingResource($listing), 'Listing retrieved successfully.');
    }

    public function update(ListingRequest $request, Listing $listing)
    {
        $this->authorize('update', $listing);
        $listing = $this->listings->update($listing, $request->validated());

        return ApiResponse::success(new ListingResource($listing), 'Listing updated successfully.');
    }

    public function destroy(Listing $listing)
    {
        $this->authorize('delete', $listing);
        $this->listings->delete($listing);

        return ApiResponse::success(null, 'Listing deleted successfully.');
    }

    public function submit(Listing $listing)
    {
        $this->authorize('update', $listing);
        $listing = $this->listings->submit($listing);

        return ApiResponse::success(new ListingResource($listing->load(['company.industry', 'company.category', 'media'])), 'Listing submitted for review.');
    }

    public function media(Request $request, Listing $listing)
    {
        $this->authorize('update', $listing);
        $request->validate([
            'file' => ['required', 'file', 'mimes:jpg,jpeg,png,webp', 'max:8192'],
        ]);

        $listing = $this->listings->addMedia($listing, $request->file('file'));

        return ApiResponse::success(new ListingResource($listing), 'Image uploaded successfully.', 201);
    }
}
