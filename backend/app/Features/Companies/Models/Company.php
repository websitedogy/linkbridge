<?php

namespace App\Features\Companies\Models;

use App\Features\Auth\Enums\VerificationStatus;
use App\Features\Auth\Models\User;
use App\Features\Companies\Enums\BusinessType;
use App\Features\Directory\Models\Category;
use App\Features\Directory\Models\Industry;
use App\Features\Directory\Models\Location;
use App\Features\Listings\Models\Listing;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Company extends Model
{
    use HasUuids, SoftDeletes;

    protected $fillable = [
        'seller_id',
        'industry_id',
        'category_id',
        'location_id',
        'company_name',
        'public_name',
        'slug',
        'founded_year',
        'country',
        'state',
        'city',
        'employee_count',
        'website',
        'business_type',
        'description',
        'status',
        'verification_status',
    ];

    protected function casts(): array
    {
        return [
            'business_type' => BusinessType::class,
            'verification_status' => VerificationStatus::class,
        ];
    }

    public function seller(): BelongsTo
    {
        return $this->belongsTo(User::class, 'seller_id');
    }

    public function industry(): BelongsTo
    {
        return $this->belongsTo(Industry::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function location(): BelongsTo
    {
        return $this->belongsTo(Location::class);
    }

    public function profile(): HasOne
    {
        return $this->hasOne(CompanyProfile::class);
    }

    public function financials(): HasOne
    {
        return $this->hasOne(CompanyFinancial::class);
    }

    public function listings(): HasMany
    {
        return $this->hasMany(Listing::class);
    }
}
