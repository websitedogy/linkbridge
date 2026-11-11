"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function BuyerInterestsPage() {
  const interests = useQuery({ queryKey: ["interests"], queryFn: marketplace.interests });

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-semibold">Your interests</h1>
      <ErrorBanner error={interests.error} />
      <ul className="space-y-3">
        {interests.data?.map((interest) => (
          <li key={interest.id} className="rounded-lg border border-zinc-200 bg-white p-4">
            <div className="flex items-center justify-between gap-4">
              <Link href={`/businesses/${interest.listing?.slug ?? ""}`} className="font-medium">
                {interest.listing?.title ?? "Listing"}
              </Link>
              <span className="text-sm">{interest.status}</span>
            </div>
            {interest.message ? <p className="mt-2 text-sm text-zinc-600">{interest.message}</p> : null}
          </li>
        ))}
      </ul>
      {interests.isSuccess && interests.data.length === 0 ? <p>You have not expressed interest yet.</p> : null}
    </div>
  );
}
