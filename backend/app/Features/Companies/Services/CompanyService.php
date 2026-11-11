<?php

namespace App\Features\Companies\Services;

use App\Features\Auth\Enums\VerificationStatus;
use App\Features\Auth\Models\User;
use App\Features\Companies\Models\Company;
use App\Features\Core\Services\AuditLogger;
use App\Features\Directory\Models\Location;
use App\Features\Listings\Enums\FinancialValueMode;
use App\Support\Slugger;
use Illuminate\Support\Facades\DB;

class CompanyService
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function create(User $seller, array $data): Company
    {
        return DB::transaction(function () use ($seller, $data) {
            $location = $this->location($data['location_id'] ?? null);

            $company = Company::query()->create([
                'seller_id' => $seller->id,
                'industry_id' => $data['industry_id'],
                'category_id' => $data['category_id'],
                'location_id' => $location?->id,
                'company_name' => $data['company_name'],
                'public_name' => $data['public_name'],
                'slug' => Slugger::unique(Company::class, $data['public_name']),
                'founded_year' => $data['founded_year'] ?? null,
                'country' => $data['country'] ?? $location?->parent?->parent?->name,
                'state' => $data['state'] ?? $location?->parent?->name,
                'city' => $data['city'] ?? $location?->name,
                'employee_count' => $data['employee_count'] ?? null,
                'website' => $data['website'] ?? null,
                'business_type' => $data['business_type'],
                'description' => $data['description'] ?? null,
                'status' => 'active',
                'verification_status' => VerificationStatus::Pending,
            ]);

            $company->profile()->create([
                'summary' => $data['description'] ?? null,
            ]);

            $company->financials()->create([
                'value_mode' => $data['financials']['value_mode'] ?? FinancialValueMode::Private->value,
                'revenue_minor' => $data['financials']['revenue_minor'] ?? null,
                'profit_minor' => $data['financials']['profit_minor'] ?? null,
                'ebitda_minor' => $data['financials']['ebitda_minor'] ?? null,
                'asking_price_minor' => $data['financials']['asking_price_minor'] ?? null,
                'assets_minor' => $data['financials']['assets_minor'] ?? null,
                'liabilities_minor' => $data['financials']['liabilities_minor'] ?? null,
                'revenue_min_minor' => $data['financials']['revenue_min_minor'] ?? null,
                'revenue_max_minor' => $data['financials']['revenue_max_minor'] ?? null,
                'profit_min_minor' => $data['financials']['profit_min_minor'] ?? null,
                'profit_max_minor' => $data['financials']['profit_max_minor'] ?? null,
                'currency' => 'INR',
            ]);

            $this->audit->log('company.created', $company, $seller);

            return $company->load(['industry', 'category', 'profile', 'financials']);
        });
    }

    public function update(Company $company, array $data): Company
    {
        return DB::transaction(function () use ($company, $data) {
            if (isset($data['public_name']) && $data['public_name'] !== $company->public_name) {
                $data['slug'] = Slugger::unique(Company::class, $data['public_name'], $company->id);
            }

            if (array_key_exists('location_id', $data)) {
                $location = $this->location($data['location_id']);
                $data['country'] = $data['country'] ?? $location?->parent?->parent?->name;
                $data['state'] = $data['state'] ?? $location?->parent?->name;
                $data['city'] = $data['city'] ?? $location?->name;
            }

            $financials = $data['financials'] ?? null;
            unset($data['financials']);

            $company->update($data);

            if (is_array($financials)) {
                $company->financials()->updateOrCreate(
                    ['company_id' => $company->id],
                    $financials,
                );
            }

            $this->audit->log('company.updated', $company);

            return $company->refresh()->load(['industry', 'category', 'profile', 'financials']);
        });
    }

    private function location(?string $id): ?Location
    {
        if ($id === null) {
            return null;
        }

        return Location::query()->with('parent.parent')->findOrFail($id);
    }
}
