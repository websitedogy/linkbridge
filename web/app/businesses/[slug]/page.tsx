"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { FormEvent, use, useState } from "react";
import { ErrorBanner } from "@/components/error-banner";
import { formatMoney, formatRange } from "@/lib/format";
import { useSession } from "@/features/auth/use-session";
import { marketplace } from "@/features/marketplace/api";

export default function ListingPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = use(params);
  const session = useSession();
  const queryClient = useQueryClient();
  const [message, setMessage] = useState("I would like to learn more about this business.");
  const [subject, setSubject] = useState("Request for more information");
  const [notice, setNotice] = useState<string | null>(null);
  const listing = useQuery({ queryKey: ["listing", slug], queryFn: () => marketplace.listing(slug) });
  const action = useMutation({
    mutationFn: async (kind: "favorite" | "interest" | "inquiry") => {
      const id = listing.data?.id;
      if (!id) {
        throw new Error("Listing is still loading.");
      }
      if (kind === "favorite") {
        return marketplace.favorite(id);
      }
      if (kind === "interest") {
        return marketplace.expressInterest(id, message);
      }
      return marketplace.inquire(id, subject, message);
    },
    onSuccess: async (result) => {
      setNotice("message" in result ? result.message : "Saved.");
      await queryClient.invalidateQueries({ queryKey: ["favorites"] });
      await queryClient.invalidateQueries({ queryKey: ["interests"] });
    },
  });

  if (listing.isLoading) {
    return <p>Loading listing…</p>;
  }

  if (listing.isError || !listing.data) {
    return <ErrorBanner error={listing.error} />;
  }

  const item = listing.data;

  return (
    <article className="space-y-6">
      <header>
        <p className="text-sm text-zinc-500">
          {[item.company.industry, item.company.category, item.company.city, item.company.state].filter(Boolean).join(" · ")}
        </p>
        <h1 className="mt-2 text-3xl font-semibold">{item.title}</h1>
        <p className="mt-2 text-lg">{item.company.public_name}</p>
      </header>
      <dl className="grid gap-4 rounded-lg border border-zinc-200 bg-white p-5 sm:grid-cols-3">
        <div>
          <dt className="text-sm text-zinc-500">Asking price</dt>
          <dd className="text-lg font-semibold">{formatMoney(item.asking_price, item.currency)}</dd>
        </div>
        <div>
          <dt className="text-sm text-zinc-500">Revenue range</dt>
          <dd>{formatRange(item.revenue_min, item.revenue_max, item.currency)}</dd>
        </div>
        <div>
          <dt className="text-sm text-zinc-500">Profit range</dt>
          <dd>{formatRange(item.profit_min, item.profit_max, item.currency)}</dd>
        </div>
      </dl>
      <p className="max-w-3xl leading-7 text-zinc-700">{item.description || item.short_description}</p>
      {session.data?.role === "BUYER" ? (
        <form
          className="space-y-3 rounded-lg border border-zinc-200 bg-white p-5"
          onSubmit={(event: FormEvent) => {
            event.preventDefault();
          }}
        >
          <h2 className="font-semibold">Contact the seller through LinksBridge</h2>
          <input className="w-full rounded-md border border-zinc-300 px-3 py-2" value={subject} onChange={(event) => setSubject(event.target.value)} />
          <textarea className="w-full rounded-md border border-zinc-300 px-3 py-2" rows={4} value={message} onChange={(event) => setMessage(event.target.value)} />
          <div className="flex flex-wrap gap-2">
            <button type="button" className="rounded-md border border-zinc-300 px-3 py-2" onClick={() => action.mutate("favorite")}>
              Save
            </button>
            <button type="button" className="rounded-md bg-zinc-900 px-3 py-2 text-white" onClick={() => action.mutate("interest")}>
              Express interest
            </button>
            <button type="button" className="rounded-md border border-zinc-900 px-3 py-2" onClick={() => action.mutate("inquiry")}>
              Send inquiry
            </button>
          </div>
          {notice ? <p className="text-sm text-green-700">{notice}</p> : null}
          <ErrorBanner error={action.error} />
        </form>
      ) : (
        <p className="text-sm text-zinc-600">Register as a buyer to save this listing or express interest.</p>
      )}
    </article>
  );
}
