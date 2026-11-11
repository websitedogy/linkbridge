import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";
import { publicEnv } from "@/lib/env";
import { TOKEN_COOKIE, tokenCookieOptions } from "@/features/auth/session";

type Context = { params: Promise<{ action: string }> };

export async function GET(_request: NextRequest, context: Context) {
  const { action } = await context.params;

  if (action !== "me") {
    return NextResponse.json({ success: false, message: "Not found." }, { status: 404 });
  }

  return forwardAuth("GET", "/auth/me");
}

export async function POST(request: NextRequest, context: Context) {
  const { action } = await context.params;

  if (!["login", "register", "logout"].includes(action)) {
    return NextResponse.json({ success: false, message: "Not found." }, { status: 404 });
  }

  const body = action === "logout" ? undefined : await request.text();
  const response = await forwardAuth(action === "logout" ? "POST" : "POST", `/auth/${action}`, body);

  if (action === "logout") {
    const outgoing = new NextResponse(await response.text(), {
      status: response.status,
      headers: { "Content-Type": "application/json" },
    });
    outgoing.cookies.set(TOKEN_COOKIE, "", { ...tokenCookieOptions, maxAge: 0 });
    return outgoing;
  }

  const payload = (await response.json()) as {
    success?: boolean;
    message?: string;
    data?: { token?: string; user?: unknown };
    errors?: Record<string, string[]>;
  };

  const outgoing = NextResponse.json(
    {
      success: payload.success ?? false,
      message: payload.message ?? "Request failed.",
      data: payload.data ? { user: payload.data.user } : null,
      errors: payload.errors,
    },
    { status: response.status },
  );

  if (response.ok && payload.success && payload.data?.token) {
    outgoing.cookies.set(TOKEN_COOKIE, payload.data.token, tokenCookieOptions);
  }

  return outgoing;
}

async function forwardAuth(method: string, path: string, body?: string) {
  const token = (await cookies()).get(TOKEN_COOKIE)?.value;
  const headers = new Headers({ Accept: "application/json" });

  if (body) {
    headers.set("Content-Type", "application/json");
  }

  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  try {
    const response = await fetch(`${publicEnv.NEXT_PUBLIC_API_URL}${path}`, {
      method,
      headers,
      body,
      cache: "no-store",
    });
    const payload = await response.text();

    return new NextResponse(payload, {
      status: response.status,
      headers: { "Content-Type": "application/json" },
    });
  } catch {
    return NextResponse.json(
      { success: false, message: "Network error. The API could not be reached." },
      { status: 503 },
    );
  }
}
