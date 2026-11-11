<?php

namespace App\Features\Listings\Services;

use App\Features\Auth\Models\User;
use App\Features\Companies\Models\Company;
use App\Features\Core\Services\AuditLogger;
use App\Features\Listings\Enums\ListingStatus;
use App\Features\Listings\Enums\ListingVisibility;
use App\Features\Listings\Models\Listing;
use App\Support\Slugger;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class ListingService
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function create(User $seller, array $data): Listing
    {
        $company = Company::query()->findOrFail($data['company_id']);

        return DB::transaction(function () use ($seller, $company, $data) {
            $listing = Listing::query()->create([
                'company_id' => $company->id,
                'seller_id' => $seller->id,
                'title' => $data['title'],
                'slug' => Slugger::unique(Listing::class, $data['title']),
                'short_description' => $data['short_description'],
                'description' => $data['description'] ?? null,
                'asking_price_minor' => $data['asking_price'] ?? null,
                'currency' => 'INR',
                'revenue_min_minor' => $data['revenue_min'] ?? null,
                'revenue_max_minor' => $data['revenue_max'] ?? null,
                'profit_min_minor' => $data['profit_min'] ?? null,
                'profit_max_minor' => $data['profit_max'] ?? null,
                'employee_min' => $data['employee_min'] ?? null,
                'employee_max' => $data['employee_max'] ?? null,
                'listing_type' => $data['listing_type'] ?? $company->business_type,
                'visibility' => $data['visibility'] ?? ListingVisibility::Public,
                'status' => ListingStatus::Draft,
            ]);

            $this->audit->log('listing.created', $listing, $seller);

            return $listing->load(['company.industry', 'company.category', 'media']);
        });
    }

    public function update(Listing $listing, array $data): Listing
    {
        if (! $listing->status->isEditable()) {
            throw ValidationException::withMessages([
                'status' => ['Only draft or rejected listings can be edited.'],
            ]);
        }

        if (isset($data['title']) && $data['title'] !== $listing->title) {
            $data['slug'] = Slugger::unique(Listing::class, $data['title'], $listing->id);
        }

        $mapped = collect($data)->mapWithKeys(function ($value, $key) {
            return match ($key) {
                'asking_price' => ['asking_price_minor' => $value],
                'revenue_min' => ['revenue_min_minor' => $value],
                'revenue_max' => ['revenue_max_minor' => $value],
                'profit_min' => ['profit_min_minor' => $value],
                'profit_max' => ['profit_max_minor' => $value],
                default => [$key => $value],
            };
        })->all();

        $listing->update($mapped);
        $this->audit->log('listing.updated', $listing);

        return $listing->refresh()->load(['company.industry', 'company.category', 'media']);
    }

    public function submit(Listing $listing): Listing
    {
        if (! in_array($listing->status, [ListingStatus::Draft, ListingStatus::Rejected], true)) {
            throw ValidationException::withMessages([
                'status' => ['This listing cannot be submitted.'],
            ]);
        }

        if ($listing->title === '' || $listing->short_description === '' || $listing->asking_price_minor === null) {
            throw ValidationException::withMessages([
                'listing' => ['A title, summary, and asking price are required before submission.'],
            ]);
        }

        $listing->update(['status' => ListingStatus::UnderReview]);
        $this->audit->log('listing.submitted', $listing, properties: ['status' => ListingStatus::UnderReview->value]);

        return $listing->refresh();
    }

    public function addMedia(Listing $listing, UploadedFile $file): Listing
    {
        if (! $listing->status->isEditable()) {
            throw ValidationException::withMessages([
                'status' => ['Media can only be added while the listing is editable.'],
            ]);
        }

        $disk = config('linksbridge.media_disk');
        $path = $file->store('listings/'.$listing->id, $disk);
        $isPrimary = ! $listing->media()->exists();

        $listing->media()->create([
            'file_type' => 'image',
            'file_path' => $path,
            'file_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getMimeType() ?: 'application/octet-stream',
            'file_size' => $file->getSize() ?: 0,
            'sort_order' => $listing->media()->count(),
            'is_primary' => $isPrimary,
        ]);

        return $listing->refresh()->load('media');
    }

    public function delete(Listing $listing): void
    {
        if (! $listing->status->isEditable()) {
            throw ValidationException::withMessages([
                'status' => ['Only draft or rejected listings can be deleted.'],
            ]);
        }

        $disk = config('linksbridge.media_disk');

        foreach ($listing->media as $media) {
            Storage::disk($disk)->delete($media->file_path);
        }

        $listing->delete();
        $this->audit->log('listing.deleted', $listing);
    }
}
