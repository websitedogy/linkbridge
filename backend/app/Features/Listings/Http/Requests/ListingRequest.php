<?php

namespace App\Features\Listings\Http\Requests;

use App\Features\Companies\Enums\BusinessType;
use App\Features\Listings\Enums\ListingVisibility;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ListingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $required = $this->isMethod('post') ? 'required' : 'sometimes';

        return [
            'company_id' => [$this->isMethod('post') ? 'required' : 'prohibited', 'uuid', 'exists:companies,id'],
            'title' => [$required, 'string', 'max:180'],
            'short_description' => [$required, 'string', 'max:500'],
            'description' => ['nullable', 'string', 'max:10000'],
            'asking_price' => ['nullable', 'integer', 'min:0'],
            'revenue_min' => ['nullable', 'integer', 'min:0'],
            'revenue_max' => ['nullable', 'integer', 'min:0'],
            'profit_min' => ['nullable', 'integer', 'min:0'],
            'profit_max' => ['nullable', 'integer', 'min:0'],
            'employee_min' => ['nullable', 'integer', 'min:0'],
            'employee_max' => ['nullable', 'integer', 'min:0'],
            'listing_type' => ['nullable', Rule::enum(BusinessType::class)],
            'visibility' => ['nullable', Rule::enum(ListingVisibility::class)],
        ];
    }
}
