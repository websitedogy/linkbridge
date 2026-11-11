<?php

namespace App\Features\Listings\Enums;

enum ListingStatus: string
{
    case Draft = 'draft';
    case Submitted = 'submitted';
    case UnderReview = 'under_review';
    case Approved = 'approved';
    case Published = 'published';
    case Paused = 'paused';
    case UnderOffer = 'under_offer';
    case Sold = 'sold';
    case Rejected = 'rejected';
    case Expired = 'expired';

    public function isEditable(): bool
    {
        return $this === self::Draft || $this === self::Rejected;
    }
}
