<?php

namespace App\Features\Buyer\Http\Resources;

use App\Features\Listings\Http\Resources\ListingResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InterestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $sellerView = $request->user()?->id === $this->listing?->seller_id || $request->user()?->isAdmin();

        return [
            'id' => $this->id,
            'listing_id' => $this->listing_id,
            'message' => $this->message,
            'status' => strtoupper($this->status->value),
            'created_at' => $this->created_at,
            'listing' => new ListingResource($this->whenLoaded('listing')),
            'buyer' => $this->when($sellerView, fn () => [
                'id' => $this->buyer?->id,
                'name' => $this->buyer?->name,
            ]),
        ];
    }
}
