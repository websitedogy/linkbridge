<?php

namespace App\Features\Buyer\Models;

use App\Features\Auth\Models\User;
use App\Features\Listings\Models\Listing;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Favorite extends Model
{
    public $incrementing = false;

    protected $primaryKey = 'user_id';

    protected $keyType = 'string';

    protected $fillable = ['user_id', 'listing_id'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function listing(): BelongsTo
    {
        return $this->belongsTo(Listing::class);
    }

    protected function setKeysForSaveQuery($query)
    {
        return $query
            ->where('user_id', $this->getAttribute('user_id'))
            ->where('listing_id', $this->getAttribute('listing_id'));
    }
}
