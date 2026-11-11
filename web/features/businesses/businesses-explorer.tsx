"use client";

import { useQuery } from "@tanstack/react-query";
import { useRouter, useSearchParams } from "next/navigation";
import { FormEvent } from "react";
import { ErrorBanner } from "@/components/error-banner";
import { ListingCard } from "@/features/listings/listing-card";
import { marketplace } from "@/features/marketplace/api";

export function BusinessesExplorer({
  title = "Businesses for sale",
  description = "Search and filter the live marketplace.",
  basePath = "/businesses",
}: {
  title?: string;
  description?: string;
  basePath?: string;
}) {
  const params = useSearchParams();
  const router = useRouter();
  const query = params.toString();
  const listings = useQuery({
    queryKey: ["listings", query],
    queryFn: () => marketplace.listings(query ? `?${query}` : ""),
  });
  const industries = useQuery({ queryKey: ["industries"], queryFn: marketplace.industries });
  const locations = useQuery({ queryKey: ["cities"], queryFn: () => marketplace.locations("city") });

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const next = new URLSearchParams();

    for (const [key, value] of form.entries()) {
      if (typeof value === "string" && value.trim() !== "") {
        next.set(key, value.trim());
      }
    }

    router.push(next.size > 0 ? `${basePath}?${next.toString()}` : basePath);
  }

  const page = Number(params.get("page") ?? "1");
  const lastPage = listings.data?.meta?.last_page ?? 1;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold">{title}</h1>
        <p className="mt-2 text-sm text-zinc-600">{description}</p>
      </div>
      <form key={params.toString()} onSubmit={onSubmit} className="grid gap-3 rounded-lg border border-zinc-200 bg-white p-4 md:grid-cols-4">
        <input name="keyword" defaultValue={params.get("keyword") ?? ""} placeholder="Keyword" className="rounded-md border border-zinc-300 px-3 py-2" />
        <select name="industry" defaultValue={params.get("industry") ?? ""} className="rounded-md border border-zinc-300 px-3 py-2">
          <option value="">All industries</option>
          {industries.data?.map((industry) => (
            <option key={industry.id} value={industry.slug}>
              {industry.name}
            </option>
          ))}
        </select>
        <select name="city" defaultValue={params.get("city") ?? ""} className="rounded-md border border-zinc-300 px-3 py-2">
          <option value="">All cities</option>
          {locations.data?.map((city) => (
            <option key={city.id} value={city.name}>
              {city.name}
            </option>
          ))}
        </select>
        <select name="sort" defaultValue={params.get("sort") ?? "newest"} className="rounded-md border border-zinc-300 px-3 py-2">
          <option value="newest">Newest</option>
          <option value="price_asc">Price: low to high</option>
          <option value="price_desc">Price: high to low</option>
        </select>
        <input name="min_price" defaultValue={params.get("min_price") ?? ""} placeholder="Min price (paise)" className="rounded-md border border-zinc-300 px-3 py-2" />
        <input name="max_price" defaultValue={params.get("max_price") ?? ""} placeholder="Max price (paise)" className="rounded-md border border-zinc-300 px-3 py-2" />
        <input name="business_type" defaultValue={params.get("business_type") ?? ""} placeholder="Business type" className="rounded-md border border-zinc-300 px-3 py-2" />
        <button className="rounded-md bg-zinc-900 px-4 py-2 text-white" type="submit">
          Apply filters
        </button>
      </form>
      <ErrorBanner error={listings.error ?? industries.error ?? locations.error} />
      <div className="grid gap-4 md:grid-cols-2">
        {listings.data?.data.map((listing) => (
          <ListingCard key={listing.id} listing={listing} />
        ))}
      </div>
      {listings.isSuccess && listings.data.data.length === 0 ? <p>No listings match these filters.</p> : null}
      <div className="flex items-center gap-3 text-sm">
        <button
          type="button"
          className="rounded-md border border-zinc-300 px-3 py-1 disabled:opacity-40"
          disabled={page <= 1}
          onClick={() => {
            const next = new URLSearchParams(params.toString());
            next.set("page", String(page - 1));
            router.push(`${basePath}?${next.toString()}`);
          }}
        >
          Previous
        </button>
        <span>
          Page {listings.data?.meta?.current_page ?? page} of {lastPage}
        </span>
        <button
          type="button"
          className="rounded-md border border-zinc-300 px-3 py-1 disabled:opacity-40"
          disabled={page >= lastPage}
          onClick={() => {
            const next = new URLSearchParams(params.toString());
            next.set("page", String(page + 1));
            router.push(`${basePath}?${next.toString()}`);
          }}
        >
          Next
        </button>
      </div>
    </div>
  );
}
