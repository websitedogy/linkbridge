"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { ErrorBanner } from "@/components/error-banner";
import { ListingCard } from "@/features/listings/listing-card";
import { marketplace } from "@/features/marketplace/api";

export default function BuyerDashboardPage() {
  const favorites = useQuery({ queryKey: ["favorites"], queryFn: marketplace.favorites });
  const interests = useQuery({ queryKey: ["interests"], queryFn: marketplace.interests });
  const recent = useQuery({ queryKey: ["listings", "recent"], queryFn: () => marketplace.listings("?per_page=3") });
  const pending = interests.data?.filter((interest) => interest.status === "PENDING").length ?? 0;

  return (
    <div className="space-y-8">
      <h1 className="text-3xl font-semibold">Buyer dashboard</h1>
      <ErrorBanner error={favorites.error ?? interests.error ?? recent.error} />
      <div className="grid gap-4 sm:grid-cols-4">
        <Stat label="Saved listings" value={favorites.data?.length ?? 0} href="/buyer/favorites" />
        <Stat label="Interested listings" value={interests.data?.length ?? 0} href="/buyer/interests" />
        <Stat label="Pending requests" value={pending} href="/buyer/interests" />
        <Stat label="Recent listings" value={recent.data?.meta?.total ?? 0} href="/businesses" />
      </div>
      <div className="grid gap-4 md:grid-cols-3">
        {recent.data?.data.map((listing) => (
          <ListingCard key={listing.id} listing={listing} />
        ))}
      </div>
    </div>
  );
}

function Stat({ label, value, href }: { label: string; value: number; href: string }) {
  return (
    <Link href={href} className="rounded-lg border border-zinc-200 bg-white p-4">
      <p className="text-sm text-zinc-500">{label}</p>
      <p className="mt-2 text-2xl font-semibold">{value}</p>
    </Link>
  );
}
