<?php

namespace App\Features\Directory\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Category extends Model
{
    use HasUuids;

    protected $fillable = ['industry_id', 'name', 'slug', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function industry(): BelongsTo
    {
        return $this->belongsTo(Industry::class);
    }
}
