<?php

namespace App\Features\Registry\Models;

use App\Features\Auth\Models\User;
use App\Features\Companies\Enums\CompanyType;
use App\Features\Registry\Enums\RegistrySubmissionStatus;
use Database\Factories\Features\Registry\Models\RegistrySubmissionFactory;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RegistrySubmission extends Model
{
    /** @use HasFactory<RegistrySubmissionFactory> */
    use HasFactory, HasUuids;

    protected $fillable = [
        'user_id',
        'company_type',
        'company_name',
        'cin',
        'director_contact',
        'director_email',
        'location',
        'latitude',
        'longitude',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'company_type' => CompanyType::class,
            'status' => RegistrySubmissionStatus::class,
            'latitude' => 'float',
            'longitude' => 'float',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
