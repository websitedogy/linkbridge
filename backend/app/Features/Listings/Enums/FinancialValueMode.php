<?php

namespace App\Features\Listings\Enums;

enum FinancialValueMode: string
{
    case Exact = 'exact';
    case Range = 'range';
    case Private = 'private';
}
