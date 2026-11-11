"use client";

import { ErrorBanner } from "@/components/error-banner";
import { useSession } from "@/features/auth/use-session";

export default function ProfilePage() {
  const session = useSession();

  if (session.isLoading) {
    return <p>Loading profile…</p>;
  }

  if (session.isError || !session.data) {
    return <ErrorBanner error={session.error ?? new Error("Sign in to view your profile.")} />;
  }

  const user = session.data;

  return (
    <div className="max-w-lg space-y-3 rounded-lg border border-zinc-200 bg-white p-6">
      <h1 className="text-2xl font-semibold">Profile</h1>
      <p>{user.name}</p>
      <p className="text-sm text-zinc-600">{user.email}</p>
      <p className="text-sm">Role: {user.role}</p>
      <p className="text-sm">Status: {user.status}</p>
    </div>
  );
}
