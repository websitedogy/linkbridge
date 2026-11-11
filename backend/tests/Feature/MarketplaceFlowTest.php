<?php

namespace Tests\Feature;

use App\Features\Auth\Models\User;
use App\Features\Directory\Models\Category;
use App\Features\Directory\Models\Industry;
use App\Features\Directory\Models\Location;
use App\Features\Listings\Enums\ListingStatus;
use App\Features\Listings\Enums\ListingVisibility;
use App\Features\Listings\Models\Listing;
use Database\Seeders\CatalogSeeder;
use Database\Seeders\RoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MarketplaceFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed([RoleSeeder::class, CatalogSeeder::class]);
    }

    public function test_register_login_logout_and_role_restrictions(): void
    {
        $seller = $this->register('seller', 'seller@example.com');
        $this->assertSame('SELLER', $seller['user']['role']);

        $buyer = $this->register('buyer', 'buyer@example.com');
        $this->assertSame('BUYER', $buyer['user']['role']);

        $this->postJson('/api/v1/auth/register', [
            'name' => 'Staff',
            'email' => 'admin@example.com',
            'mobile' => '9000000001',
            'role' => 'admin',
        ])->assertStatus(422)->assertJsonPath('success', false);

        $challenge = $this->postJson('/api/v1/auth/login', [
            'email' => 'seller@example.com',
        ])->assertOk()->assertJsonPath('success', true);

        $login = $this->postJson('/api/v1/auth/verify-otp', [
            'email' => 'seller@example.com',
            'otp' => $challenge->json('data.otp'),
        ])->assertOk()->assertJsonPath('success', true);

        $token = $login->json('data.token');

        $this->getJson('/api/v1/auth/me')->assertStatus(401)->assertJsonPath('message', 'Unauthorized.');

        $this->withToken($token)->getJson('/api/v1/auth/me')->assertOk()->assertJsonPath('data.email', 'seller@example.com');

        $this->withToken($buyer['token'])->getJson('/api/v1/seller/companies')->assertStatus(403);
        $this->withToken($seller['token'])->getJson('/api/v1/buyer/favorites')->assertStatus(403);
        $this->flushHeaders()->getJson('/api/v1/admin/listings')->assertStatus(401);

        $this->withToken($token)->postJson('/api/v1/auth/logout')->assertOk();
        $this->withToken($token)->getJson('/api/v1/auth/me')->assertStatus(401);
    }

    public function test_seller_manages_only_their_company_and_listing(): void
    {
        $seller = $this->register('seller', 'owner@example.com');
        $other = $this->register('seller', 'other@example.com');

        $created = $this->withToken($seller['token'])
            ->postJson('/api/v1/seller/companies', $this->companyPayload())
            ->assertCreated()
            ->assertJsonPath('data.public_name', 'Established Technology Company in Hyderabad');

        $companyId = $created->json('data.id');

        $this->withToken($seller['token'])
            ->putJson('/api/v1/seller/companies/'.$companyId, ['employee_count' => 40])
            ->assertOk()
            ->assertJsonPath('data.employee_count', 40);

        $this->withToken($other['token'])
            ->putJson('/api/v1/seller/companies/'.$companyId, ['employee_count' => 1])
            ->assertStatus(403);

        $listing = $this->withToken($seller['token'])
            ->postJson('/api/v1/seller/listings', [
                'company_id' => $companyId,
                'title' => 'Technology company for sale',
                'short_description' => 'A fictional software company offered for sale.',
                'asking_price' => 2500000000,
                'visibility' => 'public',
            ])
            ->assertCreated()
            ->assertJsonPath('data.status', 'DRAFT');

        $listingId = $listing->json('data.id');

        $this->withToken($seller['token'])
            ->putJson('/api/v1/seller/listings/'.$listingId, ['title' => 'Updated technology company for sale'])
            ->assertOk()
            ->assertJsonPath('data.title', 'Updated technology company for sale');

        $this->withToken($other['token'])
            ->putJson('/api/v1/seller/listings/'.$listingId, ['title' => 'Stolen'])
            ->assertStatus(403);

        $this->getJson('/api/v1/listings')->assertOk()->assertJsonPath('meta.total', 0);

        $this->withToken($seller['token'])
            ->postJson('/api/v1/seller/listings/'.$listingId.'/submit')
            ->assertOk()
            ->assertJsonPath('data.status', 'UNDER_REVIEW');

        $this->getJson('/api/v1/listings/'.$listing->json('data.slug'))->assertStatus(404);

        $admin = User::factory()->admin()->create();
        $this->withToken($admin->createToken('api')->plainTextToken)
            ->getJson('/api/v1/admin/listings?status=under_review')
            ->assertOk()
            ->assertJsonPath('meta.total', 1);

        $this->withToken($seller['token'])->getJson('/api/v1/admin/listings')->assertStatus(403);
    }

    public function test_public_search_hides_confidential_identity_and_drafts(): void
    {
        $seller = $this->register('seller', 'publisher@example.com');
        $company = $this->withToken($seller['token'])
            ->postJson('/api/v1/seller/companies', $this->companyPayload())
            ->assertCreated();

        $listing = $this->withToken($seller['token'])
            ->postJson('/api/v1/seller/listings', [
                'company_id' => $company->json('data.id'),
                'title' => 'Manufacturing business in Hyderabad',
                'short_description' => 'Demo listing for search.',
                'asking_price' => 4500000000,
                'revenue_min' => 10000000000,
                'revenue_max' => 15000000000,
                'listing_type' => 'share_sale',
            ])->assertCreated();

        Listing::query()->whereKey($listing->json('data.id'))->update([
            'status' => ListingStatus::Published,
            'visibility' => ListingVisibility::Public,
            'published_at' => now(),
        ]);

        $this->flushHeaders()->getJson('/api/v1/listings?industry=technology&city=Hyderabad&min_price=10000000')
            ->assertOk()
            ->assertJsonPath('meta.total', 1)
            ->assertJsonPath('data.0.company.public_name', 'Established Technology Company in Hyderabad')
            ->assertJsonMissingPath('data.0.company.company_name')
            ->assertJsonMissingPath('data.0.financials');

        $this->getJson('/api/v1/listings/'.$listing->json('data.slug'))
            ->assertOk()
            ->assertJsonMissingPath('data.company.company_name');
    }

    public function test_buyer_favorites_and_interest_are_unique_and_visible_to_seller(): void
    {
        $seller = $this->register('seller', 'seller2@example.com');
        $buyer = $this->register('buyer', 'buyer2@example.com');

        $company = $this->withToken($seller['token'])
            ->postJson('/api/v1/seller/companies', $this->companyPayload())
            ->json('data.id');

        $created = $this->withToken($seller['token'])
            ->postJson('/api/v1/seller/listings', [
                'company_id' => $company,
                'title' => 'Retail business for sale',
                'short_description' => 'A fictional retail listing.',
                'asking_price' => 1000000000,
            ])->json('data');

        Listing::query()->whereKey($created['id'])->update([
            'status' => ListingStatus::Published,
            'published_at' => now(),
        ]);

        $this->withToken($buyer['token'])
            ->postJson('/api/v1/buyer/favorites/'.$created['id'])
            ->assertCreated();

        $this->withToken($buyer['token'])
            ->postJson('/api/v1/buyer/favorites/'.$created['id'])
            ->assertStatus(409);

        $this->withToken($buyer['token'])
            ->getJson('/api/v1/buyer/favorites')
            ->assertOk()
            ->assertJsonCount(1, 'data');

        $this->withToken($buyer['token'])
            ->deleteJson('/api/v1/buyer/favorites/'.$created['id'])
            ->assertOk();

        $this->withToken($buyer['token'])
            ->postJson('/api/v1/buyer/listings/'.$created['id'].'/interest', ['message' => 'I would like to learn more.'])
            ->assertCreated()
            ->assertJsonPath('data.status', 'PENDING');

        $this->withToken($buyer['token'])
            ->postJson('/api/v1/buyer/listings/'.$created['id'].'/interest', ['message' => 'Again'])
            ->assertStatus(409);

        $this->withToken($seller['token'])
            ->getJson('/api/v1/seller/interests')
            ->assertOk()
            ->assertJsonPath('data.0.status', 'PENDING');

        $this->withToken($seller['token'])
            ->getJson('/api/v1/seller/listings')
            ->assertOk()
            ->assertJsonPath('meta.total', 1);
    }

    private function register(string $role, string $email): array
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Demo User',
            'email' => $email,
            'mobile' => $this->mobileFor($email),
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

    private function mobileFor(string $email): string
    {
        return '9'.str_pad((string) (abs(crc32($email)) % 1_000_000_000), 9, '0', STR_PAD_LEFT);
    }

    private function companyPayload(): array
    {
        return [
            'company_name' => 'Northwind Labs Private Limited',
            'public_name' => 'Established Technology Company in Hyderabad',
            'industry_id' => Industry::query()->where('slug', 'technology')->value('id'),
            'category_id' => Category::query()->where('slug', 'software')->value('id'),
            'location_id' => Location::query()->where('slug', 'hyderabad')->value('id'),
            'business_type' => 'share_sale',
            'employee_count' => 25,
            'description' => 'Fictional company used only in tests.',
        ];
    }
}
