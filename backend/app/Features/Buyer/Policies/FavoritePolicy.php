<?php

namespace App\Features\Buyer\Policies;

use App\Features\Auth\Models\User;
use App\Features\Buyer\Models\Favorite;

class FavoritePolicy
{
    public function view(User $user, Favorite $favorite): bool
    {
        return $user->id === $favorite->user_id;
    }

    public function delete(User $user, Favorite $favorite): bool
    {
        return $user->id === $favorite->user_id;
    }
}
