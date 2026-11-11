<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profiles', function (Blueprint $table) {
            $table->uuid('user_id')->primary();
            $table->string('profile_type');
            $table->string('display_name');
            $table->string('profile_image')->nullable();
            $table->text('bio')->nullable();
            $table->string('country')->nullable();
            $table->string('state')->nullable();
            $table->string('city')->nullable();
            $table->string('website')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });

        Schema::create('industries', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('slug')->unique();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('categories', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('industry_id');
            $table->string('name');
            $table->string('slug')->unique();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->foreign('industry_id')->references('id')->on('industries')->restrictOnDelete();
            $table->index('industry_id');
        });

        Schema::create('locations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('parent_id')->nullable();
            $table->string('type')->index();
            $table->string('name');
            $table->string('slug')->unique();
            $table->char('country_code', 2)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['type', 'parent_id']);
        });

        Schema::table('locations', function (Blueprint $table) {
            $table->foreign('parent_id')->references('id')->on('locations')->cascadeOnDelete();
        });

        Schema::create('buyer_profiles', function (Blueprint $table) {
            $table->uuid('user_id')->primary();
            $table->string('investor_type');
            $table->unsignedBigInteger('investment_min_minor')->nullable();
            $table->unsignedBigInteger('investment_max_minor')->nullable();
            $table->char('currency', 3)->default('INR');
            $table->string('acquisition_type')->nullable();
            $table->text('description')->nullable();
            $table->string('verification_status')->default('pending')->index();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });

        Schema::create('buyer_industry', function (Blueprint $table) {
            $table->uuid('buyer_user_id');
            $table->uuid('industry_id');

            $table->primary(['buyer_user_id', 'industry_id']);
            $table->foreign('buyer_user_id')->references('user_id')->on('buyer_profiles')->cascadeOnDelete();
            $table->foreign('industry_id')->references('id')->on('industries')->cascadeOnDelete();
        });

        Schema::create('buyer_location', function (Blueprint $table) {
            $table->uuid('buyer_user_id');
            $table->uuid('location_id');

            $table->primary(['buyer_user_id', 'location_id']);
            $table->foreign('buyer_user_id')->references('user_id')->on('buyer_profiles')->cascadeOnDelete();
            $table->foreign('location_id')->references('id')->on('locations')->cascadeOnDelete();
        });

        Schema::create('buyer_business_type', function (Blueprint $table) {
            $table->uuid('buyer_user_id');
            $table->string('business_type');

            $table->primary(['buyer_user_id', 'business_type']);
            $table->foreign('buyer_user_id')->references('user_id')->on('buyer_profiles')->cascadeOnDelete();
        });

        Schema::create('seller_profiles', function (Blueprint $table) {
            $table->uuid('user_id')->primary();
            $table->string('seller_type');
            $table->string('verification_status')->default('pending')->index();
            $table->text('description')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });

        Schema::create('companies', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('seller_id');
            $table->uuid('industry_id');
            $table->uuid('category_id');
            $table->uuid('location_id')->nullable();
            $table->string('company_name');
            $table->string('public_name');
            $table->string('slug')->unique();
            $table->unsignedSmallInteger('founded_year')->nullable();
            $table->string('country')->nullable()->index();
            $table->string('state')->nullable();
            $table->string('city')->nullable();
            $table->unsignedInteger('employee_count')->nullable();
            $table->string('website')->nullable();
            $table->string('business_type')->index();
            $table->text('description')->nullable();
            $table->string('status')->default('draft')->index();
            $table->string('verification_status')->default('pending')->index();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('seller_id')->references('id')->on('users')->restrictOnDelete();
            $table->foreign('industry_id')->references('id')->on('industries')->restrictOnDelete();
            $table->foreign('category_id')->references('id')->on('categories')->restrictOnDelete();
            $table->foreign('location_id')->references('id')->on('locations')->nullOnDelete();
            $table->index(['country', 'state', 'city']);
            $table->index('seller_id');
        });

        Schema::create('company_profiles', function (Blueprint $table) {
            $table->uuid('company_id')->primary();
            $table->text('summary')->nullable();
            $table->json('highlights')->nullable();
            $table->timestamps();

            $table->foreign('company_id')->references('id')->on('companies')->cascadeOnDelete();
        });

        Schema::create('company_financials', function (Blueprint $table) {
            $table->uuid('company_id')->primary();
            $table->string('value_mode')->default('private');
            $table->unsignedBigInteger('revenue_minor')->nullable();
            $table->unsignedBigInteger('profit_minor')->nullable();
            $table->unsignedBigInteger('ebitda_minor')->nullable();
            $table->unsignedBigInteger('asking_price_minor')->nullable();
            $table->unsignedBigInteger('assets_minor')->nullable();
            $table->unsignedBigInteger('liabilities_minor')->nullable();
            $table->unsignedBigInteger('revenue_min_minor')->nullable();
            $table->unsignedBigInteger('revenue_max_minor')->nullable();
            $table->unsignedBigInteger('profit_min_minor')->nullable();
            $table->unsignedBigInteger('profit_max_minor')->nullable();
            $table->char('currency', 3)->default('INR');
            $table->timestamps();

            $table->foreign('company_id')->references('id')->on('companies')->cascadeOnDelete();
        });

        Schema::create('listings', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('company_id');
            $table->uuid('seller_id');
            $table->string('title');
            $table->string('slug')->unique();
            $table->string('short_description', 500);
            $table->text('description')->nullable();
            $table->unsignedBigInteger('asking_price_minor')->nullable()->index();
            $table->char('currency', 3)->default('INR');
            $table->unsignedBigInteger('revenue_min_minor')->nullable();
            $table->unsignedBigInteger('revenue_max_minor')->nullable()->index();
            $table->unsignedBigInteger('profit_min_minor')->nullable();
            $table->unsignedBigInteger('profit_max_minor')->nullable();
            $table->unsignedInteger('employee_min')->nullable();
            $table->unsignedInteger('employee_max')->nullable();
            $table->string('listing_type')->index();
            $table->string('visibility')->default('public')->index();
            $table->string('status')->default('draft')->index();
            $table->timestamp('published_at')->nullable()->index();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('company_id')->references('id')->on('companies')->restrictOnDelete();
            $table->foreign('seller_id')->references('id')->on('users')->restrictOnDelete();
            $table->index(['status', 'visibility', 'published_at']);
            $table->index('seller_id');
        });

        Schema::create('listing_media', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('listing_id');
            $table->string('file_type');
            $table->string('file_path');
            $table->string('file_name');
            $table->string('mime_type');
            $table->unsignedBigInteger('file_size');
            $table->unsignedInteger('sort_order')->default(0);
            $table->boolean('is_primary')->default(false);
            $table->timestamps();

            $table->foreign('listing_id')->references('id')->on('listings')->cascadeOnDelete();
            $table->index(['listing_id', 'sort_order']);
        });

        Schema::create('favorites', function (Blueprint $table) {
            $table->uuid('user_id');
            $table->uuid('listing_id');
            $table->timestamps();

            $table->primary(['user_id', 'listing_id']);
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->foreign('listing_id')->references('id')->on('listings')->cascadeOnDelete();
        });

        Schema::create('buyer_interests', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('buyer_id');
            $table->uuid('listing_id');
            $table->text('message')->nullable();
            $table->string('status')->default('pending')->index();
            $table->timestamps();

            $table->unique(['buyer_id', 'listing_id']);
            $table->foreign('buyer_id')->references('id')->on('users')->cascadeOnDelete();
            $table->foreign('listing_id')->references('id')->on('listings')->cascadeOnDelete();
            $table->index(['listing_id', 'status']);
        });

        Schema::create('inquiries', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('buyer_id');
            $table->uuid('listing_id');
            $table->string('subject');
            $table->text('message');
            $table->string('status')->default('open')->index();
            $table->timestamps();

            $table->foreign('buyer_id')->references('id')->on('users')->cascadeOnDelete();
            $table->foreign('listing_id')->references('id')->on('listings')->cascadeOnDelete();
            $table->index('listing_id');
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('type');
            $table->uuidMorphs('notifiable');
            $table->text('data');
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });

        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->uuid('actor_user_id')->nullable()->index();
            $table->string('action')->index();
            $table->string('subject_type')->nullable();
            $table->uuid('subject_id')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->json('properties')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['subject_type', 'subject_id']);
            $table->foreign('actor_user_id')->references('id')->on('users')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('inquiries');
        Schema::dropIfExists('buyer_interests');
        Schema::dropIfExists('favorites');
        Schema::dropIfExists('listing_media');
        Schema::dropIfExists('listings');
        Schema::dropIfExists('company_financials');
        Schema::dropIfExists('company_profiles');
        Schema::dropIfExists('companies');
        Schema::dropIfExists('seller_profiles');
        Schema::dropIfExists('buyer_business_type');
        Schema::dropIfExists('buyer_location');
        Schema::dropIfExists('buyer_industry');
        Schema::dropIfExists('buyer_profiles');
        Schema::dropIfExists('locations');
        Schema::dropIfExists('categories');
        Schema::dropIfExists('industries');
        Schema::dropIfExists('profiles');
    }
};
