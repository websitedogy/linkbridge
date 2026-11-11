<?php

namespace App\Features\Buyer\Models;

use App\Features\Auth\Enums\VerificationStatus;
use App\Features\Auth\Models\User;
use App\Features\Directory\Models\Industry;
use App\Features\Directory\Models\Location;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class BuyerProfile extends Model
{
    protected $primaryKey = 'user_id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'user_id',
        'investor_type',
        'investment_min_minor',
        'investment_max_minor',
        'currency',
        'acquisition_type',
        'description',
        'verification_status',
    ];

    protected function casts(): array
    {
        return [
            'verification_status' => VerificationStatus::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function industries(): BelongsToMany
    {
        return $this->belongsToMany(Industry::class, 'buyer_industry', 'buyer_user_id', 'industry_id');
    }

    public function locations(): BelongsToMany
    {
        return $this->belongsToMany(Location::class, 'buyer_location', 'buyer_user_id', 'location_id');
    }
}
