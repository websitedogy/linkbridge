<?php

namespace Database\Seeders;

use App\Features\Auth\Enums\UserRole;
use App\Features\Auth\Enums\UserStatus;
use App\Features\Auth\Enums\VerificationStatus;
use App\Features\Auth\Models\User;
use App\Features\Companies\Enums\BusinessType;
use App\Features\Companies\Services\CompanyService;
use App\Features\Directory\Models\Category;
use App\Features\Directory\Models\Industry;
use App\Features\Directory\Models\Location;
use App\Features\Listings\Enums\FinancialValueMode;
use App\Features\Listings\Enums\ListingStatus;
use App\Features\Listings\Enums\ListingVisibility;
use App\Features\Listings\Models\Listing;
use Illuminate\Database\Seeder;

class DemoSeeder extends Seeder
{
    public function run(): void
    {
        $password = 'Password1!';

        $seller = $this->user('Demo Seller', 'seller@demo.linksbridge.test', UserRole::Seller, $password);
        $buyer = $this->user('Demo Buyer', 'buyer@demo.linksbridge.test', UserRole::Buyer, $password);
        $buyer->buyerProfile()->update(['verification_status' => VerificationStatus::Verified]);
        $this->user('Demo Admin', 'admin@demo.linksbridge.test', UserRole::Admin, $password);
        $this->user('Demo Super Admin', 'superadmin@demo.linksbridge.test', UserRole::SuperAdmin, $password);

        $industry = Industry::query()->where('slug', 'manufacturing')->firstOrFail();
        $category = Category::query()->where('industry_id', $industry->id)->firstOrFail();
        $city = Location::query()->where('slug', 'hyderabad')->firstOrFail();

        $company = app(CompanyService::class)->create($seller, [
            'company_name' => 'Harborline Components Private Limited',
            'public_name' => 'Established Manufacturing Company in Hyderabad',
            'industry_id' => $industry->id,
            'category_id' => $category->id,
            'location_id' => $city->id,
            'founded_year' => 2008,
            'employee_count' => 85,
            'business_type' => BusinessType::ShareSale->value,
            'description' => 'Demo company created for local testing. Not a real business.',
            'financials' => [
                'value_mode' => FinancialValueMode::Private->value,
                'revenue_minor' => 12000000000,
                'profit_minor' => 1800000000,
                'ebitda_minor' => 2100000000,
                'asking_price_minor' => 4500000000,
                'assets_minor' => 6000000000,
                'liabilities_minor' => 900000000,
            ],
        ]);

        Listing::query()->create([
            'company_id' => $company->id,
            'seller_id' => $seller->id,
            'title' => 'Established manufacturing company for sale in Hyderabad',
            'slug' => 'established-manufacturing-company-for-sale-in-hyderabad',
            'short_description' => 'Demo listing. A fictional components manufacturer offered for sale.',
            'description' => 'This record is seed data for development. It does not describe a real company.',
            'asking_price_minor' => 4500000000,
            'currency' => 'INR',
            'revenue_min_minor' => 10000000000,
            'revenue_max_minor' => 15000000000,
            'profit_min_minor' => 1500000000,
            'profit_max_minor' => 2500000000,
            'employee_min' => 50,
            'employee_max' => 100,
            'listing_type' => BusinessType::ShareSale,
            'visibility' => ListingVisibility::Public,
            'status' => ListingStatus::Published,
            'published_at' => now(),
        ]);
    }

    private function user(string $name, string $email, UserRole $role, string $password): User
    {
        $user = User::query()->create([
            'name' => $name,
            'email' => $email,
            'password' => $password,
            'role' => $role,
            'status' => UserStatus::Active,
            'email_verified_at' => now(),
        ]);

        $user->assignRole($role->value);
        $user->profile()->create([
            'profile_type' => $role->value,
            'display_name' => $name,
        ]);

        if ($role === UserRole::Buyer) {
            $user->buyerProfile()->create([
                'investor_type' => 'individual',
                'verification_status' => VerificationStatus::Pending,
            ]);
        }

        if ($role === UserRole::Seller) {
            $user->sellerProfile()->create([
                'seller_type' => 'owner',
                'verification_status' => VerificationStatus::Pending,
            ]);
        }

        return $user;
    }
}
