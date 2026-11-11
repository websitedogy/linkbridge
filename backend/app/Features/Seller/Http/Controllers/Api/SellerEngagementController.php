<?php

namespace App\Features\Seller\Http\Controllers\Api;

use App\Features\Buyer\Enums\InterestStatus;
use App\Features\Buyer\Http\Resources\InquiryResource;
use App\Features\Buyer\Http\Resources\InterestResource;
use App\Features\Buyer\Models\BuyerInterest;
use App\Features\Buyer\Models\Inquiry;
use App\Features\Seller\Services\EngagementService;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class SellerEngagementController extends Controller
{
    public function __construct(private readonly EngagementService $engagement) {}

    public function interests(Request $request)
    {
        $rows = BuyerInterest::query()
            ->whereHas('listing', fn ($query) => $query->where('seller_id', $request->user()->id))
            ->with(['listing.company', 'buyer'])
            ->latest()
            ->get();

        return ApiResponse::success(InterestResource::collection($rows), 'Interests retrieved successfully.');
    }

    public function updateInterest(Request $request, BuyerInterest $interest)
    {
        $this->authorize('update', $interest);
        abort_unless($interest->listing?->seller_id === $request->user()->id, 403);

        $data = $request->validate([
            'status' => ['required', Rule::in(['viewed', 'accepted', 'rejected'])],
        ]);

        $interest = $this->engagement->updateInterest($interest, InterestStatus::from($data['status']));

        return ApiResponse::success(new InterestResource($interest->load(['listing', 'buyer'])), 'Interest updated.');
    }

    public function inquiries(Request $request)
    {
        $rows = Inquiry::query()
            ->whereHas('listing', fn ($query) => $query->where('seller_id', $request->user()->id))
            ->with(['listing', 'buyer'])
            ->latest()
            ->get();

        return ApiResponse::success(InquiryResource::collection($rows), 'Inquiries retrieved successfully.');
    }
}
