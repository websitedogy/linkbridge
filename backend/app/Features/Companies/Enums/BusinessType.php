<?php

namespace App\Features\Companies\Enums;

enum BusinessType: string
{
    case AssetSale = 'asset_sale';
    case ShareSale = 'share_sale';
    case Franchise = 'franchise';
    case PartnershipInterest = 'partnership_interest';
    case Other = 'other';
}
