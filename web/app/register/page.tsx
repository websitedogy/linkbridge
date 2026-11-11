"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { FormEvent, useState } from "react";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function RegisterPage() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState<"buyer" | "seller">("buyer");
  const register = useMutation({
    mutationFn: () =>
      marketplace.register({
        name,
        email,
        password,
        password_confirmation: password,
        role,
      }),
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
        register.mutate();
      }}
    >
      <h1 className="text-2xl font-semibold">Create an account</h1>
      <label className="block text-sm">
        Name
        <input className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" value={name} onChange={(event) => setName(event.target.value)} required />
      </label>
      <label className="block text-sm">
        Email
        <input className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" type="email" value={email} onChange={(event) => setEmail(event.target.value)} required />
      </label>
      <label className="block text-sm">
        Password
        <input className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" type="password" minLength={8} value={password} onChange={(event) => setPassword(event.target.value)} required />
      </label>
      <fieldset className="text-sm">
        <legend>I am a</legend>
        <label className="mr-4">
          <input type="radio" name="role" checked={role === "buyer"} onChange={() => setRole("buyer")} /> Buyer
        </label>
        <label>
          <input type="radio" name="role" checked={role === "seller"} onChange={() => setRole("seller")} /> Seller
        </label>
      </fieldset>
      <ErrorBanner error={register.error} />
      <button className="w-full rounded-md bg-zinc-900 px-4 py-2 text-white" type="submit" disabled={register.isPending}>
        Register
      </button>
      <p className="text-sm">
        Already registered? <Link href="/login">Log in</Link>
      </p>
    </form>
  );
}
