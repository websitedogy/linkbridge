<?php

namespace App\Features\Companies\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CompanyResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'company_name' => $this->company_name,
            'public_name' => $this->public_name,
            'slug' => $this->slug,
            'industry_id' => $this->industry_id,
            'category_id' => $this->category_id,
            'industry' => $this->industry?->name,
            'category' => $this->category?->name,
            'location_id' => $this->location_id,
            'founded_year' => $this->founded_year,
            'country' => $this->country,
            'state' => $this->state,
            'city' => $this->city,
            'employee_count' => $this->employee_count,
            'website' => $this->website,
            'business_type' => $this->business_type?->value,
            'description' => $this->description,
            'status' => strtoupper((string) $this->status),
            'verification_status' => strtoupper($this->verification_status->value),
            'financials' => $this->whenLoaded('financials', fn () => [
                'value_mode' => strtoupper($this->financials->value_mode->value),
                'revenue' => $this->financials->revenue_minor,
                'profit' => $this->financials->profit_minor,
                'ebitda' => $this->financials->ebitda_minor,
                'asking_price' => $this->financials->asking_price_minor,
                'assets' => $this->financials->assets_minor,
                'liabilities' => $this->financials->liabilities_minor,
                'revenue_min' => $this->financials->revenue_min_minor,
                'revenue_max' => $this->financials->revenue_max_minor,
                'profit_min' => $this->financials->profit_min_minor,
                'profit_max' => $this->financials->profit_max_minor,
                'currency' => $this->financials->currency,
            ]),
        ];
    }
}
