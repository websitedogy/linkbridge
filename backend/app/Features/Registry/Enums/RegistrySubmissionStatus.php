<?php

namespace App\Features\Registry\Enums;

enum RegistrySubmissionStatus: string
{
    case Unverified = 'unverified';

    public function label(): string
    {
        return match ($this) {
            self::Unverified => 'Unverified',
        };
    }
}
