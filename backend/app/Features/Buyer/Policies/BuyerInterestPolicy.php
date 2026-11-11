<?php

namespace App\Features\Buyer\Policies;

use App\Features\Auth\Models\User;
use App\Features\Buyer\Models\BuyerInterest;

class BuyerInterestPolicy
{
    public function view(User $user, BuyerInterest $interest): bool
    {
        return $user->isAdmin()
            || $user->id === $interest->buyer_id
            || $user->id === $interest->listing?->seller_id;
    }

    public function update(User $user, BuyerInterest $interest): bool
    {
        return $user->id === $interest->listing?->seller_id || $user->id === $interest->buyer_id;
    }
}
