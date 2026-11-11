<?php

namespace App\Features\Listings\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class ListingMedia extends Model
{
    use HasUuids;

    protected $fillable = [
        'listing_id',
        'file_type',
        'file_path',
        'file_name',
        'mime_type',
        'file_size',
        'sort_order',
        'is_primary',
    ];

    protected function casts(): array
    {
        return ['is_primary' => 'boolean'];
    }

    public function listing(): BelongsTo
    {
        return $this->belongsTo(Listing::class);
    }

    public function url(): ?string
    {
        $disk = config('linksbridge.media_disk');

        if ($disk === 's3') {
            return Storage::disk('s3')->temporaryUrl($this->file_path, now()->addMinutes(10));
        }

        return Storage::disk($disk)->url($this->file_path);
    }
}
