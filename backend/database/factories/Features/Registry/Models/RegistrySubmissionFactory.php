<?php

namespace Database\Factories\Features\Registry\Models;

use App\Features\Auth\Models\User;
use App\Features\Companies\Enums\CompanyType;
use App\Features\Registry\Enums\RegistrySubmissionStatus;
use App\Features\Registry\Models\RegistrySubmission;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RegistrySubmission>
 */
class RegistrySubmissionFactory extends Factory
{
    protected $model = RegistrySubmission::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'company_type' => CompanyType::PvtLtd,
            'company_name' => fake()->company(),
            'cin' => 'U'.fake()->numerify('#####').'TG'.fake()->numerify('####').'PTC'.fake()->numerify('######'),
            'director_contact' => '9'.fake()->numerify('#########'),
            'director_email' => fake()->unique()->safeEmail(),
            'location' => 'Hyderabad, Telangana, India',
            'latitude' => 17.385044,
            'longitude' => 78.486671,
            'status' => RegistrySubmissionStatus::Unverified,
        ];
    }
}
