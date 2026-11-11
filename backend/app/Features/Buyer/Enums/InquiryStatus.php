<?php

namespace App\Features\Buyer\Enums;

enum InquiryStatus: string
{
    case Open = 'open';
    case Answered = 'answered';
    case Closed = 'closed';
}
