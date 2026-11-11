<?php

namespace App\Features\Seller\Models;

use App\Features\Auth\Enums\VerificationStatus;
use App\Features\Auth\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SellerProfile extends Model
{
    protected $primaryKey = 'user_id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'user_id',
        'seller_type',
        'verification_status',
        'description',
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
}
