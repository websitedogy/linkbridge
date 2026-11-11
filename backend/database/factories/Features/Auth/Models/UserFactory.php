<?php

namespace Database\Factories\Features\Auth\Models;

use App\Features\Auth\Enums\UserRole;
use App\Features\Auth\Enums\UserStatus;
use App\Features\Auth\Enums\VerificationStatus;
use App\Features\Auth\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    protected $model = User::class;

    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function configure(): static
    {
        return $this->afterCreating(function (User $user) {
            if (! $user->hasRole($user->role->value)) {
                $user->assignRole($user->role->value);
            }

            $user->profile()->firstOrCreate(
                ['user_id' => $user->id],
                ['profile_type' => $user->role->value, 'display_name' => $user->name],
            );

            if ($user->role === UserRole::Buyer) {
                $user->buyerProfile()->firstOrCreate(
                    ['user_id' => $user->id],
                    ['investor_type' => 'individual', 'verification_status' => VerificationStatus::Pending],
                );
            }

            if ($user->role === UserRole::Seller) {
                $user->sellerProfile()->firstOrCreate(
                    ['user_id' => $user->id],
                    ['seller_type' => 'owner', 'verification_status' => VerificationStatus::Pending],
                );
            }
        });
    }

    public function seller(): static
    {
        return $this->state(fn () => ['role' => UserRole::Seller]);
    }

    public function admin(): static
    {
        return $this->state(fn () => ['role' => UserRole::Admin]);
    }

    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
