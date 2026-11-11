<?php

namespace App\Features\Companies\Http\Requests;

use App\Features\Companies\Enums\BusinessType;
use App\Features\Listings\Enums\FinancialValueMode;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CompanyRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $required = $this->isMethod('post') ? 'required' : 'sometimes';

        return [
            'company_name' => [$required, 'string', 'max:255'],
            'public_name' => [$required, 'string', 'max:255'],
            'industry_id' => [$required, 'uuid', 'exists:industries,id'],
            'category_id' => [$required, 'uuid', 'exists:categories,id'],
            'location_id' => ['nullable', 'uuid', 'exists:locations,id'],
            'founded_year' => ['nullable', 'integer', 'min:1800', 'max:'.date('Y')],
            'country' => ['nullable', 'string', 'max:120'],
            'state' => ['nullable', 'string', 'max:120'],
            'city' => ['nullable', 'string', 'max:120'],
            'employee_count' => ['nullable', 'integer', 'min:0'],
            'website' => ['nullable', 'url', 'max:255'],
            'business_type' => [$required, Rule::enum(BusinessType::class)],
            'description' => ['nullable', 'string', 'max:5000'],
            'financials' => ['sometimes', 'array'],
            'financials.value_mode' => ['sometimes', Rule::enum(FinancialValueMode::class)],
            'financials.revenue_minor' => ['nullable', 'integer', 'min:0'],
            'financials.profit_minor' => ['nullable', 'integer', 'min:0'],
            'financials.ebitda_minor' => ['nullable', 'integer', 'min:0'],
            'financials.asking_price_minor' => ['nullable', 'integer', 'min:0'],
            'financials.assets_minor' => ['nullable', 'integer', 'min:0'],
            'financials.liabilities_minor' => ['nullable', 'integer', 'min:0'],
            'financials.revenue_min_minor' => ['nullable', 'integer', 'min:0'],
            'financials.revenue_max_minor' => ['nullable', 'integer', 'min:0'],
            'financials.profit_min_minor' => ['nullable', 'integer', 'min:0'],
            'financials.profit_max_minor' => ['nullable', 'integer', 'min:0'],
        ];
    }
}
