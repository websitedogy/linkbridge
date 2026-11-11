<?php

namespace App\Features\Buyer\Models;

use App\Features\Auth\Models\User;
use App\Features\Buyer\Enums\InterestStatus;
use App\Features\Listings\Models\Listing;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BuyerInterest extends Model
{
    use HasUuids;

    protected $fillable = ['buyer_id', 'listing_id', 'message', 'status'];

    protected function casts(): array
    {
        return ['status' => InterestStatus::class];
    }

    public function buyer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'buyer_id');
    }

    public function listing(): BelongsTo
    {
        return $this->belongsTo(Listing::class);
    }
}
