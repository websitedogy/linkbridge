<?php

namespace App\Features\Auth\Enums;

enum UserRole: string
{
    case Buyer = 'buyer';
    case Seller = 'seller';
    case Admin = 'admin';
    case SuperAdmin = 'super_admin';

    public function isStaff(): bool
    {
        return $this === self::Admin || $this === self::SuperAdmin;
    }

    public function isPublic(): bool
    {
        return $this === self::Buyer || $this === self::Seller;
    }
}
