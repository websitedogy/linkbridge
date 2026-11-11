"use client";

import Link from "next/link";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function SellerDashboardPage() {
  const queryClient = useQueryClient();
  const companies = useQuery({ queryKey: ["companies"], queryFn: marketplace.companies });
  const listings = useQuery({ queryKey: ["seller-listings"], queryFn: marketplace.sellerListings });
  const interests = useQuery({ queryKey: ["seller-interests"], queryFn: marketplace.sellerInterests });
  const inquiries = useQuery({ queryKey: ["seller-inquiries"], queryFn: marketplace.sellerInquiries });
  const update = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => marketplace.updateInterest(id, status),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["seller-interests"] }),
  });
  const rows = listings.data?.data ?? [];
  const published = rows.filter((listing) => listing.status === "PUBLISHED").length;
  const pending = rows.filter((listing) => listing.status === "UNDER_REVIEW" || listing.status === "SUBMITTED").length;

  return (
    <div className="space-y-8">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-3xl font-semibold">Seller dashboard</h1>
        <div className="flex gap-2">
          <Link href="/seller/companies/create" className="rounded-md border border-zinc-300 px-3 py-2 text-sm">
            Create company
          </Link>
          <Link href="/seller/listings/create" className="rounded-md bg-zinc-900 px-3 py-2 text-sm text-white">
            Create listing
          </Link>
        </div>
      </div>
      <ErrorBanner error={companies.error ?? listings.error ?? interests.error ?? inquiries.error ?? update.error} />
      <div className="grid gap-4 sm:grid-cols-5">
        <Stat label="Companies" value={companies.data?.length ?? 0} />
        <Stat label="Listings" value={listings.data?.meta?.total ?? rows.length} />
        <Stat label="Published" value={published} />
        <Stat label="Pending review" value={pending} />
        <Stat label="Buyer interests" value={interests.data?.length ?? 0} />
      </div>
      <section className="space-y-3">
        <h2 className="text-xl font-semibold">Listing status</h2>
        <ul className="space-y-2">
          {rows.map((listing) => (
            <li key={listing.id} className="flex items-center justify-between rounded-lg border border-zinc-200 bg-white px-4 py-3">
              <span>{listing.title}</span>
              <span className="text-sm">
                {listing.status} · <Link href={`/seller/listings/${listing.id}/edit`}>Edit</Link>
              </span>
            </li>
          ))}
        </ul>
      </section>
      <section className="space-y-3">
        <h2 className="text-xl font-semibold">Buyer interests</h2>
        <ul className="space-y-2">
          {interests.data?.map((interest) => (
            <li key={interest.id} className="rounded-lg border border-zinc-200 bg-white p-4">
              <p className="font-medium">{interest.listing?.title}</p>
              <p className="text-sm text-zinc-600">
                {interest.buyer?.name ?? "Buyer"} · {interest.status}
              </p>
              {interest.message ? <p className="mt-2 text-sm">{interest.message}</p> : null}
              <div className="mt-3 flex gap-2">
                <button type="button" className="rounded-md border px-2 py-1 text-sm" onClick={() => update.mutate({ id: interest.id, status: "viewed" })}>
                  Mark viewed
                </button>
                <button type="button" className="rounded-md border px-2 py-1 text-sm" onClick={() => update.mutate({ id: interest.id, status: "accepted" })}>
                  Accept
                </button>
                <button type="button" className="rounded-md border px-2 py-1 text-sm" onClick={() => update.mutate({ id: interest.id, status: "rejected" })}>
                  Reject
                </button>
              </div>
            </li>
          ))}
        </ul>
        {interests.isSuccess && interests.data.length === 0 ? <p className="text-sm text-zinc-600">No buyer interest yet.</p> : null}
      </section>
      <section className="space-y-3">
        <h2 className="text-xl font-semibold">Inquiries</h2>
        <ul className="space-y-2">
          {inquiries.data?.map((inquiry) => (
            <li key={inquiry.id} className="rounded-lg border border-zinc-200 bg-white p-4">
              <p className="font-medium">{inquiry.subject}</p>
              <p className="text-sm text-zinc-600">{inquiry.message}</p>
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-lg border border-zinc-200 bg-white p-4">
      <p className="text-sm text-zinc-500">{label}</p>
      <p className="mt-2 text-2xl font-semibold">{value}</p>
    </div>
  );
}
