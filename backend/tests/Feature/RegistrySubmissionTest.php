<?php

namespace Tests\Feature;

use App\Features\Auth\Models\User;
use App\Features\Companies\Enums\CompanyType;
use App\Features\Registry\Enums\RegistrySubmissionStatus;
use App\Features\Registry\Models\RegistrySubmission;
use Database\Seeders\RoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RegistrySubmissionTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleSeeder::class);
    }

    public function test_guest_cannot_submit_registry_cin(): void
    {
        $this->postJson('/api/v1/registry-submissions', $this->payload())
            ->assertStatus(401);
    }

    public function test_authenticated_user_submits_unverified_company_and_sees_it_on_sell_list(): void
    {
        $user = $this->register('buyer', 'seller-cin@example.com');

        $created = $this->withToken($user['token'])
            ->postJson('/api/v1/registry-submissions', $this->payload([
                'cin' => null,
            ]))
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.company_name', 'Harborline Components Private Limited')
            ->assertJsonPath('data.status', 'UNVERIFIED')
            ->assertJsonPath('data.submitted_by.email', 'seller-cin@example.com');

        $this->assertDatabaseHas('registry_submissions', [
            'id' => $created->json('data.id'),
            'company_name' => 'Harborline Components Private Limited',
            'status' => RegistrySubmissionStatus::Unverified->value,
            'cin' => null,
        ]);

        $this->withToken($user['token'])
            ->getJson('/api/v1/registry-submissions')
            ->assertOk()
            ->assertJsonPath('data.0.company_name', 'Harborline Components Private Limited')
            ->assertJsonPath('data.0.status', 'UNVERIFIED');
    }

    public function test_user_only_sees_their_own_submissions(): void
    {
        $owner = $this->register('buyer', 'owner-cin@example.com');
        $other = $this->register('buyer', 'other-cin@example.com');

        RegistrySubmission::factory()->create([
            'user_id' => $other['user']['id'],
            'company_name' => 'Other Company',
        ]);

        $this->withToken($owner['token'])
            ->postJson('/api/v1/registry-submissions', $this->payload())
            ->assertCreated();

        $list = $this->withToken($owner['token'])
            ->getJson('/api/v1/registry-submissions')
            ->assertOk()
            ->json('data');

        $this->assertCount(1, $list);
        $this->assertSame('Harborline Components Private Limited', $list[0]['company_name']);
    }

    public function test_invalid_cin_is_rejected_and_valid_cin_is_stored(): void
    {
        $user = $this->register('buyer', 'cin-check@example.com');

        $this->withToken($user['token'])
            ->postJson('/api/v1/registry-submissions', $this->payload([
                'cin' => 'ABC',
            ]))
            ->assertStatus(422);

        $this->withToken($user['token'])
            ->postJson('/api/v1/registry-submissions', $this->payload([
                'cin' => 'u72900tg2018ptc123456',
            ]))
            ->assertCreated()
            ->assertJsonPath('data.cin', 'U72900TG2018PTC123456');
    }

    public function test_admin_sees_who_submitted_the_details(): void
    {
        $user = $this->register('buyer', 'from-user@example.com');
        $this->withToken($user['token'])
            ->postJson('/api/v1/registry-submissions', $this->payload())
            ->assertCreated();

        $admin = User::factory()->admin()->create();

        $this->withToken($user['token'])
            ->getJson('/api/v1/admin/registry-submissions')
            ->assertStatus(403);

        $this->withToken($admin->createToken('api')->plainTextToken)
            ->getJson('/api/v1/admin/registry-submissions')
            ->assertOk()
            ->assertJsonPath('data.0.company_name', 'Harborline Components Private Limited')
            ->assertJsonPath('data.0.submitted_by.name', 'Demo User')
            ->assertJsonPath('data.0.submitted_by.email', 'from-user@example.com')
            ->assertJsonPath('data.0.status', 'UNVERIFIED');
    }

    public function test_company_type_must_be_known(): void
    {
        $user = $this->register('buyer', 'type-check@example.com');

        $this->withToken($user['token'])
            ->postJson('/api/v1/registry-submissions', $this->payload([
                'company_type' => 'unknown',
            ]))
            ->assertStatus(422);
    }

    /**
     * @param  array<string, mixed>  $overrides
     * @return array<string, mixed>
     */
    private function payload(array $overrides = []): array
    {
        return array_merge([
            'company_type' => CompanyType::PvtLtd->value,
            'company_name' => 'Harborline Components Private Limited',
            'cin' => 'U72900TG2018PTC123456',
            'director_contact' => '9876543210',
            'director_email' => 'director@example.com',
            'location' => 'Hyderabad, Telangana, India',
            'latitude' => 17.385044,
            'longitude' => 78.486671,
        ], $overrides);
    }

    /**
     * @return array{token: string, user: array<string, mixed>}
     */
    private function register(string $role, string $email): array
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Demo User',
            'email' => $email,
            'mobile' => '9'.str_pad((string) (abs(crc32($email)) % 1_000_000_000), 9, '0', STR_PAD_LEFT),
            'role' => $role,
        ])->assertCreated();

        $verified = $this->postJson('/api/v1/auth/verify-otp', [
            'email' => $email,
            'otp' => $response->json('data.otp'),
        ])->assertOk();

        return [
            'token' => $verified->json('data.token'),
            'user' => $verified->json('data.user'),
        ];
    }
}
