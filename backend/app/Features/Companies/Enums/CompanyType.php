<?php

namespace App\Features\Companies\Enums;

enum CompanyType: string
{
    case Llp = 'llp';
    case PvtLtd = 'pvt-ltd';
    case Opc = 'opc';
    case Section8 = 'section-8';
    case Nidhi = 'nidhi';
    case Producer = 'producer';

    public function label(): string
    {
        return match ($this) {
            self::Llp => 'LLP',
            self::PvtLtd => 'Pvt Ltd',
            self::Opc => 'OPC',
            self::Section8 => 'Section 8 Company',
            self::Nidhi => 'Nidhi Company',
            self::Producer => 'Producer Company',
        };
    }
}
