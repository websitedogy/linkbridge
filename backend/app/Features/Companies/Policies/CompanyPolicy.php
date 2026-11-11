<?php

namespace App\Features\Companies\Policies;

use App\Features\Auth\Models\User;
use App\Features\Companies\Models\Company;

class CompanyPolicy
{
    public function view(User $user, Company $company): bool
    {
        return $user->isAdmin() || $user->id === $company->seller_id;
    }

    public function create(User $user): bool
    {
        return $user->role?->value === 'seller';
    }

    public function update(User $user, Company $company): bool
    {
        return $user->id === $company->seller_id;
    }
}
