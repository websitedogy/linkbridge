<?php

namespace App\Features\Seller\Services;

use App\Features\Auth\Models\User;
use App\Features\Buyer\Enums\InquiryStatus;
use App\Features\Buyer\Enums\InterestStatus;
use App\Features\Buyer\Models\BuyerInterest;
use App\Features\Buyer\Models\Favorite;
use App\Features\Buyer\Models\Inquiry;
use App\Features\Buyer\Notifications\BuyerInterested;
use App\Features\Core\Services\AuditLogger;
use App\Features\Listings\Models\Listing;
use Illuminate\Validation\ValidationException;

class EngagementService
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function favorite(User $buyer, Listing $listing): Favorite
    {
        $this->assertNotOwner($buyer, $listing);

        $favorite = Favorite::query()->firstOrCreate([
            'user_id' => $buyer->id,
            'listing_id' => $listing->id,
        ]);

        if (! $favorite->wasRecentlyCreated) {
            throw ValidationException::withMessages([
                'listing' => ['This listing is already saved.'],
            ])->status(409);
        }

        return $favorite;
    }

    public function unfavorite(User $buyer, Listing $listing): void
    {
        Favorite::query()
            ->where('user_id', $buyer->id)
            ->where('listing_id', $listing->id)
            ->delete();
    }

    public function expressInterest(User $buyer, Listing $listing, ?string $message): BuyerInterest
    {
        $this->assertNotOwner($buyer, $listing);

        if (BuyerInterest::query()->where('buyer_id', $buyer->id)->where('listing_id', $listing->id)->exists()) {
            throw ValidationException::withMessages([
                'listing' => ['You have already expressed interest in this listing.'],
            ])->status(409);
        }

        $interest = BuyerInterest::query()->create([
            'buyer_id' => $buyer->id,
            'listing_id' => $listing->id,
            'message' => $message,
            'status' => InterestStatus::Pending,
        ]);

        $listing->seller?->notify(new BuyerInterested($interest));
        $this->audit->log('interest.created', $interest, $buyer);

        return $interest->load('listing');
    }

    public function updateInterest(BuyerInterest $interest, InterestStatus $status): BuyerInterest
    {
        $interest->update(['status' => $status]);
        $this->audit->log('interest.updated', $interest, properties: ['status' => $status->value]);

        return $interest->refresh();
    }

    public function inquire(User $buyer, Listing $listing, string $subject, string $message): Inquiry
    {
        $this->assertNotOwner($buyer, $listing);

        $inquiry = Inquiry::query()->create([
            'buyer_id' => $buyer->id,
            'listing_id' => $listing->id,
            'subject' => $subject,
            'message' => $message,
            'status' => InquiryStatus::Open,
        ]);

        $this->audit->log('inquiry.created', $inquiry, $buyer);

        return $inquiry;
    }

    private function assertNotOwner(User $buyer, Listing $listing): void
    {
        if ($buyer->id === $listing->seller_id) {
            throw ValidationException::withMessages([
                'listing' => ['You cannot do this on your own listing.'],
            ]);
        }
    }
}
