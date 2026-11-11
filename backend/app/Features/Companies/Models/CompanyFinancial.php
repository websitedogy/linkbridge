<?php

namespace App\Features\Companies\Models;

use App\Features\Listings\Enums\FinancialValueMode;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CompanyFinancial extends Model
{
    protected $primaryKey = 'company_id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'value_mode',
        'revenue_minor',
        'profit_minor',
        'ebitda_minor',
        'asking_price_minor',
        'assets_minor',
        'liabilities_minor',
        'revenue_min_minor',
        'revenue_max_minor',
        'profit_min_minor',
        'profit_max_minor',
        'currency',
    ];

    protected function casts(): array
    {
        return ['value_mode' => FinancialValueMode::class];
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }
}
