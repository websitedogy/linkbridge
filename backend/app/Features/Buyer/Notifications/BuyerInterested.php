<?php

namespace App\Features\Buyer\Notifications;

use App\Features\Buyer\Models\BuyerInterest;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class BuyerInterested extends Notification
{
    use Queueable;

    public function __construct(private readonly BuyerInterest $interest) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toArray(object $notifiable): array
    {
        return [
            'interest_id' => $this->interest->id,
            'listing_id' => $this->interest->listing_id,
            'message' => 'A buyer expressed interest in a listing.',
        ];
    }
}
