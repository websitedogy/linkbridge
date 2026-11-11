<?php

namespace App\Features\Buyer\Http\Controllers\Api;

use App\Features\Buyer\Enums\InterestStatus;
use App\Features\Buyer\Http\Resources\InquiryResource;
use App\Features\Buyer\Http\Resources\InterestResource;
use App\Features\Buyer\Models\BuyerInterest;
use App\Features\Buyer\Models\Favorite;
use App\Features\Listings\Http\Resources\ListingResource;
use App\Features\Listings\Models\Listing;
use App\Features\Seller\Services\EngagementService;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class BuyerController extends Controller
{
    public function __construct(private readonly EngagementService $engagement) {}

    public function favorites(Request $request)
    {
        $ids = Favorite::query()->where('user_id', $request->user()->id)->pluck('listing_id');
        $listings = Listing::query()
            ->with(['company.industry', 'company.category', 'media'])
            ->whereIn('id', $ids)
            ->get();

        return ApiResponse::success(ListingResource::collection($listings), 'Favorites retrieved successfully.');
    }

    public function favorite(Request $request, Listing $listing)
    {
        $listing = Listing::query()->visibleTo($request->user())->whereKey($listing->id)->firstOrFail();
        $this->engagement->favorite($request->user(), $listing);

        return ApiResponse::success(null, 'Listing saved.', 201);
    }

    public function unfavorite(Request $request, Listing $listing)
    {
        $this->engagement->unfavorite($request->user(), $listing);

        return ApiResponse::success(null, 'Listing removed from favorites.');
    }

    public function interests(Request $request)
    {
        $rows = BuyerInterest::query()
            ->where('buyer_id', $request->user()->id)
            ->with(['listing.company.industry', 'listing.company.category', 'listing.media'])
            ->latest()
            ->get();

        return ApiResponse::success(InterestResource::collection($rows), 'Interests retrieved successfully.');
    }

    public function interest(Request $request, Listing $listing)
    {
        $request->validate(['message' => ['nullable', 'string', 'max:2000']]);
        $listing = Listing::query()->visibleTo($request->user())->whereKey($listing->id)->firstOrFail();
        $interest = $this->engagement->expressInterest($request->user(), $listing, $request->input('message'));

        return ApiResponse::success(new InterestResource($interest), 'Interest sent to the seller.', 201);
    }

    public function withdraw(Request $request, BuyerInterest $interest)
    {
        $this->authorize('update', $interest);
        abort_unless($interest->buyer_id === $request->user()->id, 403);
        $interest = $this->engagement->updateInterest($interest, InterestStatus::Withdrawn);

        return ApiResponse::success(new InterestResource($interest), 'Interest withdrawn.');
    }

    public function inquiry(Request $request, Listing $listing)
    {
        $data = $request->validate([
            'subject' => ['required', 'string', 'max:180'],
            'message' => ['required', 'string', 'max:5000'],
        ]);
        $listing = Listing::query()->visibleTo($request->user())->whereKey($listing->id)->firstOrFail();
        $inquiry = $this->engagement->inquire($request->user(), $listing, $data['subject'], $data['message']);

        return ApiResponse::success(new InquiryResource($inquiry), 'Inquiry sent.', 201);
    }
}
