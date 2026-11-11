<?php

namespace App\Features\Listings\Models;

use App\Features\Auth\Enums\VerificationStatus;
use App\Features\Auth\Models\User;
use App\Features\Buyer\Models\BuyerInterest;
use App\Features\Buyer\Models\Inquiry;
use App\Features\Companies\Enums\BusinessType;
use App\Features\Companies\Models\Company;
use App\Features\Listings\Enums\ListingStatus;
use App\Features\Listings\Enums\ListingVisibility;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Listing extends Model
{
    use HasUuids, SoftDeletes;

    protected $fillable = [
        'company_id',
        'seller_id',
        'title',
        'slug',
        'short_description',
        'description',
        'asking_price_minor',
        'currency',
        'revenue_min_minor',
        'revenue_max_minor',
        'profit_min_minor',
        'profit_max_minor',
        'employee_min',
        'employee_max',
        'listing_type',
        'visibility',
        'status',
        'published_at',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'listing_type' => BusinessType::class,
            'visibility' => ListingVisibility::class,
            'status' => ListingStatus::class,
            'published_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function seller(): BelongsTo
    {
        return $this->belongsTo(User::class, 'seller_id');
    }

    public function media(): HasMany
    {
        return $this->hasMany(ListingMedia::class)->orderBy('sort_order');
    }

    public function interests(): HasMany
    {
        return $this->hasMany(BuyerInterest::class);
    }

    public function inquiries(): HasMany
    {
        return $this->hasMany(Inquiry::class);
    }

    public function scopeVisibleTo(Builder $query, ?User $user): Builder
    {
        return $query->where('status', ListingStatus::Published)->where(function (Builder $visible) use ($user) {
            $visible->where('visibility', ListingVisibility::Public);

            if ($user === null) {
                return;
            }

            $visible->orWhere('visibility', ListingVisibility::RegisteredUsers);

            if ($user->buyerProfile?->verification_status === VerificationStatus::Verified) {
                $visible->orWhere('visibility', ListingVisibility::VerifiedBuyers);
            }
        });
    }
}
