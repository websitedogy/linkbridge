<?php

namespace App\Features\Listings\Http\Controllers\Api;

use App\Features\Listings\Http\Requests\ListingIndexRequest;
use App\Features\Listings\Http\Resources\ListingResource;
use App\Features\Listings\Models\Listing;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Database\Eloquent\Builder;

class ListingController extends Controller
{
    public function index(ListingIndexRequest $request)
    {
        $filters = $request->validated();
        $perPage = (int) ($filters['per_page'] ?? 20);

        $query = Listing::query()
            ->with(['company.industry', 'company.category', 'media'])
            ->visibleTo($request->user())
            ->when($filters['keyword'] ?? null, function (Builder $builder, string $keyword) {
                $builder->where(function (Builder $inner) use ($keyword) {
                    $inner->where('title', 'like', "%{$keyword}%")
                        ->orWhere('short_description', 'like', "%{$keyword}%")
                        ->orWhereHas('company', fn (Builder $company) => $company->where('public_name', 'like', "%{$keyword}%"));
                });
            })
            ->when($filters['industry'] ?? null, fn (Builder $builder, string $industry) => $builder->whereHas(
                'company.industry',
                fn (Builder $row) => $row->where('slug', $industry),
            ))
            ->when($filters['category'] ?? null, fn (Builder $builder, string $category) => $builder->whereHas(
                'company.category',
                fn (Builder $row) => $row->where('slug', $category),
            ))
            ->when($filters['country'] ?? null, fn (Builder $builder, string $country) => $builder->whereHas(
                'company',
                fn (Builder $row) => $row->where('country', $country),
            ))
            ->when($filters['state'] ?? null, fn (Builder $builder, string $state) => $builder->whereHas(
                'company',
                fn (Builder $row) => $row->where('state', $state),
            ))
            ->when($filters['city'] ?? null, fn (Builder $builder, string $city) => $builder->whereHas(
                'company',
                fn (Builder $row) => $row->where('city', $city),
            ))
            ->when(isset($filters['min_price']), fn (Builder $builder) => $builder->where('asking_price_minor', '>=', $filters['min_price']))
            ->when(isset($filters['max_price']), fn (Builder $builder) => $builder->where('asking_price_minor', '<=', $filters['max_price']))
            ->when(isset($filters['min_revenue']), fn (Builder $builder) => $builder->where('revenue_max_minor', '>=', $filters['min_revenue']))
            ->when(isset($filters['max_revenue']), fn (Builder $builder) => $builder->where('revenue_min_minor', '<=', $filters['max_revenue']))
            ->when($filters['business_type'] ?? null, fn (Builder $builder, string $type) => $builder->where('listing_type', $type));

        match ($filters['sort'] ?? 'newest') {
            'price_asc' => $query->orderBy('asking_price_minor'),
            'price_desc' => $query->orderByDesc('asking_price_minor'),
            default => $query->orderByDesc('published_at'),
        };

        $page = $query->paginate($perPage)->withQueryString();

        return ApiResponse::success(
            ListingResource::collection($page->items()),
            'Listings retrieved successfully.',
            meta: [
                'current_page' => $page->currentPage(),
                'per_page' => $page->perPage(),
                'total' => $page->total(),
                'last_page' => $page->lastPage(),
            ],
        );
    }

    public function show(string $slug)
    {
        $listing = Listing::query()
            ->with(['company.industry', 'company.category', 'company.financials', 'media'])
            ->where('slug', $slug)
            ->visibleTo(request()->user())
            ->firstOrFail();

        return ApiResponse::success(new ListingResource($listing), 'Listing retrieved successfully.');
    }
}
