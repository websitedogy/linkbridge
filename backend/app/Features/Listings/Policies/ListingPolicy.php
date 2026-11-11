<?php

namespace App\Features\Listings\Policies;

use App\Features\Auth\Models\User;
use App\Features\Listings\Models\Listing;

class ListingPolicy
{
    public function view(User $user, Listing $listing): bool
    {
        return $user->isAdmin() || $user->id === $listing->seller_id;
    }

    public function create(User $user): bool
    {
        return $user->role?->value === 'seller';
    }

    public function update(User $user, Listing $listing): bool
    {
        return $user->id === $listing->seller_id;
    }

    public function delete(User $user, Listing $listing): bool
    {
        return $user->id === $listing->seller_id;
    }
}
