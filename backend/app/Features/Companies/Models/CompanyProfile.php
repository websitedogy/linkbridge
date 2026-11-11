<?php

namespace App\Features\Companies\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CompanyProfile extends Model
{
    protected $primaryKey = 'company_id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = ['company_id', 'summary', 'highlights'];

    protected function casts(): array
    {
        return ['highlights' => 'array'];
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }
}
