<?php

namespace App\Features\Assistant\Services;

use App\Features\Listings\Models\Listing;

class AssistantService
{
    public function reply(string $message): array
    {
        $text = mb_strtolower(trim($message));

        if (preg_match('/^(hi|hello|hey|help)\b/u', $text) === 1) {
            return $this->answer(
                'I can help you buy a business, list one for sale, check a CIN, or look through licences. What do you want to do?',
                [
                    ['label' => 'Businesses for sale', 'href' => '/sale'],
                    ['label' => 'Buy', 'href' => '/buy'],
                    ['label' => 'CIN Verify', 'href' => '/cin-verify'],
                ],
            );
        }

        if ($this->mentions($text, ['cin', 'verify', 'corporate identification'])) {
            return $this->answer(
                'Open CIN Verify and enter a 21-character CIN. I will read the listing status, state, year, and company type from it.',
                [['label' => 'CIN Verify', 'href' => '/cin-verify']],
            );
        }

        if ($this->mentions($text, ['licence', 'license', 'llp', 'pvt', 'opc', 'nidhi', 'section 8', 'producer'])) {
            return $this->answer(
                'Licences lists LLP, Pvt Ltd, OPC, Section 8, Nidhi, and Producer Company. Choose one to search the marketplace.',
                [['label' => 'Licences', 'href' => '/licences']],
            );
        }

        if ($this->mentions($text, ['sell', 'list my', 'listing'])) {
            return $this->answer(
                'Sale shows businesses already published. To offer your own company, create a company, save a listing as a draft, then submit it for review.',
                [
                    ['label' => 'Businesses for sale', 'href' => '/sale'],
                    ['label' => 'Create a listing', 'href' => '/seller/listings/create'],
                ],
            );
        }

        if ($this->mentions($text, ['buy', 'interest', 'favourite', 'favorite', 'save'])) {
            return $this->answer(
                'Open a listing from Buy, then save it or express interest. The seller sees that request on their dashboard. Sign in as a buyer first.',
                [['label' => 'Buy a business', 'href' => '/buy']],
            );
        }

        $keyword = trim(str_replace(['%', '_'], '', $message));

        if ($keyword === '') {
            return $this->answer(
                'Tell me a city, industry, or company type and I will look for a published listing.',
                [['label' => 'Browse businesses', 'href' => '/buy']],
            );
        }

        $listings = Listing::query()
            ->with('company')
            ->visibleTo(null)
            ->where(function ($query) use ($keyword) {
                $query->where('title', 'like', "%{$keyword}%")
                    ->orWhere('short_description', 'like', "%{$keyword}%")
                    ->orWhereHas('company', function ($company) use ($keyword) {
                        $company->where('public_name', 'like', "%{$keyword}%")
                            ->orWhere('city', 'like', "%{$keyword}%");
                    });
            })
            ->latest('published_at')
            ->limit(3)
            ->get();

        if ($listings->isEmpty()) {
            return $this->answer(
                'I could not match that with a published listing. Try a city, industry, or company type, or browse everything that is for sale.',
                [['label' => 'Browse businesses', 'href' => '/buy']],
            );
        }

        $lines = $listings->map(function (Listing $listing) {
            $place = $listing->company?->city;

            return $place ? "{$listing->title} in {$place}" : $listing->title;
        })->implode("\n");

        return $this->answer(
            "I found these published listings:\n{$lines}",
            $listings->map(fn (Listing $listing) => [
                'label' => $listing->title,
                'href' => '/businesses/'.$listing->slug,
            ])->all(),
        );
    }

    private function mentions(string $text, array $needles): bool
    {
        foreach ($needles as $needle) {
            if (str_contains($text, $needle)) {
                return true;
            }
        }

        return false;
    }

    private function answer(string $reply, array $links): array
    {
        return [
            'reply' => $reply,
            'links' => $links,
        ];
    }
}
