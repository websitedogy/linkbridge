<?php

namespace App\Features\Buyer\Policies;

use App\Features\Auth\Models\User;
use App\Features\Buyer\Models\Inquiry;

class InquiryPolicy
{
    public function view(User $user, Inquiry $inquiry): bool
    {
        return $user->isAdmin()
            || $user->id === $inquiry->buyer_id
            || $user->id === $inquiry->listing?->seller_id;
    }
}
