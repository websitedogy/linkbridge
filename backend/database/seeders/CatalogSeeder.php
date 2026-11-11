<?php

namespace Database\Seeders;

use App\Features\Directory\Enums\LocationType;
use App\Features\Directory\Models\Category;
use App\Features\Directory\Models\Industry;
use App\Features\Directory\Models\Location;
use App\Support\Slugger;
use Illuminate\Database\Seeder;

class CatalogSeeder extends Seeder
{
    public function run(): void
    {
        $industries = [
            'Technology' => ['Software', 'IT Services'],
            'Manufacturing' => ['Industrial Components', 'Textiles'],
            'Healthcare' => ['Clinics', 'Diagnostics'],
            'Retail' => ['Specialty Retail'],
            'Food & Beverage' => ['Packaged Foods'],
            'Education' => ['Training'],
            'Construction' => ['Contracting'],
            'Logistics' => ['Warehousing'],
            'Automotive' => ['Dealerships'],
            'Professional Services' => ['Consulting'],
        ];

        foreach ($industries as $name => $categories) {
            $industry = Industry::query()->create([
                'name' => $name,
                'slug' => Slugger::unique(Industry::class, $name),
                'is_active' => true,
            ]);

            foreach ($categories as $category) {
                Category::query()->create([
                    'industry_id' => $industry->id,
                    'name' => $category,
                    'slug' => Slugger::unique(Category::class, $category),
                    'is_active' => true,
                ]);
            }
        }

        $india = Location::query()->create([
            'type' => LocationType::Country,
            'name' => 'India',
            'slug' => 'india',
            'country_code' => 'IN',
            'is_active' => true,
        ]);

        $telangana = Location::query()->create([
            'parent_id' => $india->id,
            'type' => LocationType::State,
            'name' => 'Telangana',
            'slug' => 'telangana',
            'country_code' => 'IN',
            'is_active' => true,
        ]);

        $karnataka = Location::query()->create([
            'parent_id' => $india->id,
            'type' => LocationType::State,
            'name' => 'Karnataka',
            'slug' => 'karnataka',
            'country_code' => 'IN',
            'is_active' => true,
        ]);

        Location::query()->create([
            'parent_id' => $telangana->id,
            'type' => LocationType::City,
            'name' => 'Hyderabad',
            'slug' => 'hyderabad',
            'country_code' => 'IN',
            'is_active' => true,
        ]);

        Location::query()->create([
            'parent_id' => $karnataka->id,
            'type' => LocationType::City,
            'name' => 'Bengaluru',
            'slug' => 'bengaluru',
            'country_code' => 'IN',
            'is_active' => true,
        ]);
    }
}
