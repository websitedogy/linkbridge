<?php

namespace App\Features\Auth\Enums;

enum VerificationStatus: string
{
    case Pending = 'pending';
    case UnderReview = 'under_review';
    case Verified = 'verified';
    case Rejected = 'rejected';
}
