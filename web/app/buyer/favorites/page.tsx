"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ErrorBanner } from "@/components/error-banner";
import { ListingCard } from "@/features/listings/listing-card";
import { marketplace } from "@/features/marketplace/api";

export default function FavoritesPage() {
  const queryClient = useQueryClient();
  const favorites = useQuery({ queryKey: ["favorites"], queryFn: marketplace.favorites });
  const remove = useMutation({
    mutationFn: (id: string) => marketplace.unfavorite(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["favorites"] }),
  });

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-semibold">Saved listings</h1>
      <ErrorBanner error={favorites.error ?? remove.error} />
      <div className="grid gap-4 md:grid-cols-2">
        {favorites.data?.map((listing) => (
          <div key={listing.id} className="space-y-2">
            <ListingCard listing={listing} />
            <button type="button" className="text-sm underline" onClick={() => remove.mutate(listing.id)}>
              Remove
            </button>
          </div>
        ))}
      </div>
      {favorites.isSuccess && favorites.data.length === 0 ? <p>You have not saved any listings yet.</p> : null}
    </div>
  );
}
