import Link from "next/link";
import { formatMoney, formatRange } from "@/lib/format";
import type { Listing } from "@/lib/types/marketplace";

export function ListingCard({ listing }: { listing: Listing }) {
  return (
    <article className="flex h-full flex-col rounded-lg border border-zinc-200 bg-white p-5">
      <p className="text-xs uppercase tracking-wide text-zinc-500">
        {[listing.company.industry, listing.company.city].filter(Boolean).join(" · ") || "Business"}
      </p>
      <h2 className="mt-2 text-lg font-semibold">
        <Link href={`/businesses/${listing.slug}`}>{listing.title}</Link>
      </h2>
      <p className="mt-2 flex-1 text-sm text-zinc-600">{listing.short_description}</p>
      <dl className="mt-4 grid grid-cols-2 gap-3 text-sm">
        <div>
          <dt className="text-zinc-500">Asking price</dt>
          <dd className="font-medium">{formatMoney(listing.asking_price, listing.currency)}</dd>
        </div>
        <div>
          <dt className="text-zinc-500">Revenue</dt>
          <dd className="font-medium">{formatRange(listing.revenue_min, listing.revenue_max, listing.currency)}</dd>
        </div>
      </dl>
      <p className="mt-4 text-sm font-medium">{listing.company.public_name}</p>
    </article>
  );
}
