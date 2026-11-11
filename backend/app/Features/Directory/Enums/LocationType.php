<?php

namespace App\Features\Directory\Enums;

enum LocationType: string
{
    case Country = 'country';
    case State = 'state';
    case City = 'city';
}
