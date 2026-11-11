"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { FormEvent, useState } from "react";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function LoginPage() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const login = useMutation({
    mutationFn: () => marketplace.login({ email, password }),
    onSuccess: async (user) => {
      await queryClient.invalidateQueries({ queryKey: ["me"] });
      router.push(user.role === "SELLER" ? "/seller/dashboard" : "/buyer/dashboard");
    },
  });

  return (
    <form
      className="mx-auto max-w-md space-y-4 rounded-lg border border-zinc-200 bg-white p-6"
      onSubmit={(event: FormEvent) => {
        event.preventDefault();
        login.mutate();
      }}
    >
      <h1 className="text-2xl font-semibold">Log in</h1>
      <label className="block text-sm">
        Email
        <input className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" type="email" value={email} onChange={(event) => setEmail(event.target.value)} required />
      </label>
      <label className="block text-sm">
        Password
        <input className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" type="password" value={password} onChange={(event) => setPassword(event.target.value)} required />
      </label>
      <ErrorBanner error={login.error} />
      <button className="w-full rounded-md bg-zinc-900 px-4 py-2 text-white" type="submit" disabled={login.isPending}>
        Log in
      </button>
      <p className="text-sm">
        New here? <Link href="/register">Create an account</Link>
      </p>
    </form>
  );
}
