import { cookies } from "next/headers";
import { publicEnv } from "../env";
import { TOKEN_COOKIE } from "@/features/auth/session";

export async function laravelFetch(path: string, init: RequestInit = {}): Promise<Response> {
  const token = (await cookies()).get(TOKEN_COOKIE)?.value;
  const headers = new Headers(init.headers);
  headers.set("Accept", "application/json");

  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  return fetch(`${publicEnv.NEXT_PUBLIC_API_URL}${path}`, {
    ...init,
    headers,
    cache: "no-store",
  });
}
