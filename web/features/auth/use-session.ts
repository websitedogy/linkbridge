"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { marketplace } from "@/features/marketplace/api";
import { ApiError } from "@/lib/api/errors";

export function useSession() {
  return useQuery({
    queryKey: ["me"],
    queryFn: () => marketplace.me(),
    retry: false,
  });
}

export function useLogout() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => marketplace.logout(),
    onSettled: async () => {
      await queryClient.invalidateQueries({ queryKey: ["me"] });
      queryClient.removeQueries({ queryKey: ["me"] });
    },
  });
}

export function isUnauthorized(error: unknown): boolean {
  return error instanceof ApiError && error.status === 401;
}
