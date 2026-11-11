"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { FormEvent } from "react";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function CreateListingPage() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const companies = useQuery({ queryKey: ["companies"], queryFn: marketplace.companies });
  const create = useMutation({
    mutationFn: (body: Record<string, unknown>) => marketplace.createListing(body),
    onSuccess: async (listing) => {
      await queryClient.invalidateQueries({ queryKey: ["seller-listings"] });
      router.push(`/seller/listings/${listing.id}/edit`);
    },
  });

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    create.mutate({
      company_id: form.get("company_id"),
      title: form.get("title"),
      short_description: form.get("short_description"),
      description: form.get("description"),
      asking_price: form.get("asking_price") ? Number(form.get("asking_price")) : null,
      revenue_min: form.get("revenue_min") ? Number(form.get("revenue_min")) : null,
      revenue_max: form.get("revenue_max") ? Number(form.get("revenue_max")) : null,
      profit_min: form.get("profit_min") ? Number(form.get("profit_min")) : null,
      profit_max: form.get("profit_max") ? Number(form.get("profit_max")) : null,
      visibility: form.get("visibility"),
      listing_type: form.get("listing_type"),
    });
  }

  return (
    <form onSubmit={onSubmit} className="mx-auto max-w-2xl space-y-4 rounded-lg border border-zinc-200 bg-white p-6">
      <h1 className="text-2xl font-semibold">Create listing draft</h1>
      <label className="block text-sm">
        Company
        <select name="company_id" required className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2">
          <option value="">Select a company</option>
          {companies.data?.map((company) => (
            <option key={company.id} value={company.id}>
              {company.public_name}
            </option>
          ))}
        </select>
      </label>
      <label className="block text-sm">
        Title
        <input name="title" required className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
      </label>
      <label className="block text-sm">
        Summary
        <input name="short_description" required className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
      </label>
      <label className="block text-sm">
        Description
        <textarea name="description" className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" rows={4} />
      </label>
      <label className="block text-sm">
        Asking price (minor units)
        <input name="asking_price" type="number" min={0} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
      </label>
      <div className="grid gap-3 sm:grid-cols-2">
        <label className="text-sm">
          Revenue min
          <input name="revenue_min" type="number" min={0} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
        </label>
        <label className="text-sm">
          Revenue max
          <input name="revenue_max" type="number" min={0} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
        </label>
        <label className="text-sm">
          Profit min
          <input name="profit_min" type="number" min={0} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
        </label>
        <label className="text-sm">
          Profit max
          <input name="profit_max" type="number" min={0} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
        </label>
      </div>
      <label className="block text-sm">
        Visibility
        <select name="visibility" className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" defaultValue="public">
          <option value="public">Public</option>
          <option value="registered_users">Registered users</option>
          <option value="verified_buyers">Verified buyers</option>
          <option value="confidential">Confidential</option>
        </select>
      </label>
      <label className="block text-sm">
        Listing type
        <select name="listing_type" className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" defaultValue="share_sale">
          <option value="share_sale">Share sale</option>
          <option value="asset_sale">Asset sale</option>
          <option value="franchise">Franchise</option>
          <option value="partnership_interest">Partnership interest</option>
          <option value="other">Other</option>
        </select>
      </label>
      <ErrorBanner error={create.error ?? companies.error} />
      <button className="rounded-md bg-zinc-900 px-4 py-2 text-white" type="submit" disabled={create.isPending}>
        Save draft
      </button>
    </form>
  );
}
