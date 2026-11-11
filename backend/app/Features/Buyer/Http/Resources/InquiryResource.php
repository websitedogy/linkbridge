<?php

namespace App\Features\Buyer\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InquiryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'listing_id' => $this->listing_id,
            'subject' => $this->subject,
            'message' => $this->message,
            'status' => strtoupper($this->status->value),
            'created_at' => $this->created_at,
            'buyer_name' => $this->when(
                $request->user()?->id === $this->listing?->seller_id,
                $this->buyer?->name,
            ),
        ];
    }
}
