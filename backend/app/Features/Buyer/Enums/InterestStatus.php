<?php

namespace App\Features\Buyer\Enums;

enum InterestStatus: string
{
    case Pending = 'pending';
    case Viewed = 'viewed';
    case Accepted = 'accepted';
    case Rejected = 'rejected';
    case Withdrawn = 'withdrawn';
}
