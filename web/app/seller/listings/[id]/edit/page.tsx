"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { FormEvent, use, useState } from "react";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function EditListingPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const queryClient = useQueryClient();
  const [notice, setNotice] = useState<string | null>(null);
  const listing = useQuery({ queryKey: ["seller-listing", id], queryFn: () => marketplace.sellerListing(id) });
  const save = useMutation({
    mutationFn: (body: Record<string, unknown>) => marketplace.updateListing(id, body),
    onSuccess: async () => {
      setNotice("Draft saved.");
      await queryClient.invalidateQueries({ queryKey: ["seller-listing", id] });
    },
  });
  const submit = useMutation({
    mutationFn: () => marketplace.submitListing(id),
    onSuccess: async () => {
      setNotice("Listing submitted and is now under review.");
      await queryClient.invalidateQueries({ queryKey: ["seller-listing", id] });
      await queryClient.invalidateQueries({ queryKey: ["seller-listings"] });
    },
  });
  const upload = useMutation({
    mutationFn: (file: File) => marketplace.uploadMedia(id, file),
    onSuccess: async () => {
      setNotice("Image uploaded.");
      await queryClient.invalidateQueries({ queryKey: ["seller-listing", id] });
    },
  });

  if (listing.isLoading) {
    return <p>Loading listing…</p>;
  }

  if (listing.isError || !listing.data) {
    return <ErrorBanner error={listing.error} />;
  }

  const item = listing.data;
  const editable = item.status === "DRAFT" || item.status === "REJECTED";

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    save.mutate({
      title: form.get("title"),
      short_description: form.get("short_description"),
      description: form.get("description"),
      asking_price: form.get("asking_price") ? Number(form.get("asking_price")) : null,
      revenue_min: form.get("revenue_min") ? Number(form.get("revenue_min")) : null,
      revenue_max: form.get("revenue_max") ? Number(form.get("revenue_max")) : null,
      visibility: String(form.get("visibility") ?? "public").toLowerCase(),
    });
  }

  return (
    <div className="mx-auto max-w-2xl space-y-4">
      <h1 className="text-2xl font-semibold">Edit listing</h1>
      <p className="text-sm">Status: {item.status}</p>
      <form onSubmit={onSubmit} className="space-y-4 rounded-lg border border-zinc-200 bg-white p-6">
        <label className="block text-sm">
          Title
          <input name="title" defaultValue={item.title} disabled={!editable} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
        </label>
        <label className="block text-sm">
          Summary
          <input name="short_description" defaultValue={item.short_description} disabled={!editable} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
        </label>
        <label className="block text-sm">
          Description
          <textarea name="description" defaultValue={item.description ?? ""} disabled={!editable} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" rows={4} />
        </label>
        <label className="block text-sm">
          Asking price (minor units)
          <input name="asking_price" type="number" defaultValue={item.asking_price ?? ""} disabled={!editable} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
        </label>
        <div className="grid gap-3 sm:grid-cols-2">
          <label className="text-sm">
            Revenue min
            <input name="revenue_min" type="number" defaultValue={item.revenue_min ?? ""} disabled={!editable} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
          </label>
          <label className="text-sm">
            Revenue max
            <input name="revenue_max" type="number" defaultValue={item.revenue_max ?? ""} disabled={!editable} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
          </label>
        </div>
        <label className="block text-sm">
          Visibility
          <select name="visibility" defaultValue={item.visibility.toLowerCase()} disabled={!editable} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2">
            <option value="public">Public</option>
            <option value="registered_users">Registered users</option>
            <option value="verified_buyers">Verified buyers</option>
            <option value="confidential">Confidential</option>
          </select>
        </label>
        {editable ? (
          <div className="flex gap-2">
            <button className="rounded-md border border-zinc-300 px-4 py-2" type="submit" disabled={save.isPending}>
              Save draft
            </button>
            <button
              className="rounded-md bg-zinc-900 px-4 py-2 text-white"
              type="button"
              disabled={submit.isPending}
              onClick={() => submit.mutate()}
            >
              Submit for review
            </button>
          </div>
        ) : (
          <p className="text-sm text-zinc-600">This listing can no longer be edited.</p>
        )}
      </form>
      {editable ? (
        <label className="block rounded-lg border border-zinc-200 bg-white p-4 text-sm">
          Listing image
          <input
            className="mt-2 block"
            type="file"
            accept="image/jpeg,image/png,image/webp"
            onChange={(event) => {
              const file = event.target.files?.[0];
              if (file) {
                upload.mutate(file);
              }
            }}
          />
        </label>
      ) : null}
      {notice ? <p className="text-sm text-green-700">{notice}</p> : null}
      <ErrorBanner error={save.error ?? submit.error ?? upload.error} />
    </div>
  );
}
