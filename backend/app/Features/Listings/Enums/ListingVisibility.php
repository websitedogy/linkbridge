<?php

namespace App\Features\Listings\Enums;

enum ListingVisibility: string
{
    case Public = 'public';
    case RegisteredUsers = 'registered_users';
    case VerifiedBuyers = 'verified_buyers';
    case Confidential = 'confidential';
}
