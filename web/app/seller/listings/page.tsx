"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function SellerListingsPage() {
  const listings = useQuery({ queryKey: ["seller-listings"], queryFn: marketplace.sellerListings });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-semibold">Listings</h1>
        <Link href="/seller/listings/create" className="rounded-md bg-zinc-900 px-3 py-2 text-sm text-white">
          Create listing
        </Link>
      </div>
      <ErrorBanner error={listings.error} />
      <ul className="space-y-3">
        {listings.data?.data.map((listing) => (
          <li key={listing.id} className="flex items-center justify-between rounded-lg border border-zinc-200 bg-white px-4 py-3">
            <div>
              <p className="font-medium">{listing.title}</p>
              <p className="text-sm text-zinc-500">{listing.status}</p>
            </div>
            <Link href={`/seller/listings/${listing.id}/edit`}>Edit</Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
