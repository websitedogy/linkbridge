<?php

namespace Tests\Feature;

use App\Features\Auth\Enums\UserStatus;
use App\Features\Auth\Models\User;
use Database\Seeders\RoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthMessagesTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleSeeder::class);
    }

    public function test_login_unknown_user_asks_to_sign_up(): void
    {
        $this->postJson('/api/v1/auth/login', [
            'email' => 'missing@example.com',
        ])
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('errors.email.0', 'No account found. Please sign up.');
    }

    public function test_register_sends_otp_and_verify_activates_account(): void
    {
        $created = $this->postJson('/api/v1/auth/register', [
            'name' => 'Demo Buyer',
            'email' => 'buyer@example.com',
            'mobile' => '9991112222',
            'role' => 'buyer',
        ])->assertCreated()->assertJsonPath('data.email', 'buyer@example.com');

        $this->assertNotEmpty($created->json('data.otp'));
        $this->assertSame(
            UserStatus::PendingVerification,
            User::query()->where('email', 'buyer@example.com')->first()?->status,
        );

        $this->postJson('/api/v1/auth/verify-otp', [
            'email' => 'buyer@example.com',
            'otp' => '000000',
        ])
            ->assertStatus(422)
            ->assertJsonPath('errors.otp.0', 'The OTP is incorrect.');

        $this->postJson('/api/v1/auth/verify-otp', [
            'email' => 'buyer@example.com',
            'otp' => $created->json('data.otp'),
        ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.email', 'buyer@example.com');

        $this->assertSame(
            UserStatus::Active,
            User::query()->where('email', 'buyer@example.com')->first()?->status,
        );
    }

    public function test_register_duplicate_email_asks_to_login(): void
    {
        $this->registerVerifiedBuyer();

        $this->postJson('/api/v1/auth/register', [
            'name' => 'Another Buyer',
            'email' => 'buyer@example.com',
            'mobile' => '9991112223',
            'role' => 'buyer',
        ])
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('errors.email.0', 'This account already exists. Please login.');
    }

    public function test_register_duplicate_mobile_asks_to_login(): void
    {
        $this->postJson('/api/v1/auth/register', [
            'name' => 'Mobile Buyer',
            'email' => 'mobile@example.com',
            'mobile' => '9876543210',
            'role' => 'buyer',
        ])->assertCreated();

        $this->postJson('/api/v1/auth/register', [
            'name' => 'Second Mobile',
            'email' => 'second@example.com',
            'mobile' => '9876543210',
            'role' => 'seller',
        ])
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('errors.mobile.0', 'This account already exists. Please login.');
    }

    private function registerVerifiedBuyer(): void
    {
        $created = $this->postJson('/api/v1/auth/register', [
            'name' => 'Demo Buyer',
            'email' => 'buyer@example.com',
            'mobile' => '9991112222',
            'role' => 'buyer',
        ])->assertCreated();

        $this->postJson('/api/v1/auth/verify-otp', [
            'email' => 'buyer@example.com',
            'otp' => $created->json('data.otp'),
        ])->assertOk();
    }
}
