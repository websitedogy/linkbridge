<?php

namespace App\Features\Listings\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ListingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $owner = $request->user()
            && ($request->user()->id === $this->seller_id || $request->user()->isAdmin());

        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'short_description' => $this->short_description,
            'description' => $this->description,
            'asking_price' => $this->asking_price_minor,
            'currency' => $this->currency,
            'revenue_min' => $this->revenue_min_minor,
            'revenue_max' => $this->revenue_max_minor,
            'profit_min' => $this->profit_min_minor,
            'profit_max' => $this->profit_max_minor,
            'employee_min' => $this->employee_min,
            'employee_max' => $this->employee_max,
            'listing_type' => $this->listing_type?->value,
            'visibility' => strtoupper($this->visibility->value),
            'status' => $owner ? strtoupper($this->status->value) : ($this->status->value === 'published' ? 'PUBLISHED' : null),
            'published_at' => $this->published_at,
            'company' => [
                'id' => $this->company?->id,
                'public_name' => $this->company?->public_name,
                'company_name' => $this->when($owner, $this->company?->company_name),
                'slug' => $this->company?->slug,
                'industry' => $this->company?->industry?->name,
                'industry_slug' => $this->company?->industry?->slug,
                'category' => $this->company?->category?->name,
                'category_slug' => $this->company?->category?->slug,
                'country' => $this->company?->country,
                'state' => $this->company?->state,
                'city' => $this->company?->city,
                'founded_year' => $this->company?->founded_year,
                'employee_count' => $this->company?->employee_count,
                'business_type' => $this->company?->business_type?->value,
                'website' => $this->when($owner, $this->company?->website),
                'description' => $this->company?->description,
            ],
            'financials' => $this->when($owner, fn () => [
                'value_mode' => strtoupper($this->company?->financials?->value_mode?->value ?? 'private'),
                'revenue' => $this->company?->financials?->revenue_minor,
                'profit' => $this->company?->financials?->profit_minor,
                'ebitda' => $this->company?->financials?->ebitda_minor,
                'assets' => $this->company?->financials?->assets_minor,
                'liabilities' => $this->company?->financials?->liabilities_minor,
            ]),
            'media' => ListingMediaResource::collection($this->whenLoaded('media')),
        ];
    }
}
