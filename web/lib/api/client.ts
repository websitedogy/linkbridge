import { ApiError, messageForStatus } from "./errors";
import type { ApiMeta, ApiSuccess } from "../types/marketplace";

type ApiEnvelope<T> = {
  success?: boolean;
  message?: string;
  data?: T;
  errors?: Record<string, string[]>;
  meta?: ApiMeta;
};

async function readEnvelope<T>(response: Response): Promise<ApiSuccess<T>> {
  const payload = (await response.json().catch(() => null)) as ApiEnvelope<T> | null;

  if (!response.ok || !payload || payload.success !== true || payload.data === undefined) {
    throw new ApiError(
      response.status || 500,
      messageForStatus(response.status, payload?.message ?? "Request failed."),
      payload?.errors,
    );
  }

  return {
    success: true,
    message: payload.message ?? "",
    data: payload.data,
    meta: payload.meta,
  };
}

export async function apiRequest<T>(
  path: string,
  options: { method?: string; body?: unknown; formData?: FormData } = {},
): Promise<ApiSuccess<T>> {
  const headers = new Headers({ Accept: "application/json" });
  let body: BodyInit | undefined;

  if (options.formData) {
    body = options.formData;
  } else if (options.body !== undefined) {
    headers.set("Content-Type", "application/json");
    body = JSON.stringify(options.body);
  }

  let response: Response;

  try {
    response = await fetch(`/api/proxy${path}`, {
      method: options.method ?? "GET",
      headers,
      body,
    });
  } catch {
    throw new ApiError(0, messageForStatus(0, ""));
  }

  return readEnvelope<T>(response);
}

export async function authRequest<T>(
  action: "login" | "register" | "logout" | "me",
  body?: unknown,
): Promise<ApiSuccess<T>> {
  let response: Response;

  try {
    response = await fetch(`/api/auth/${action}`, {
      method: action === "me" ? "GET" : "POST",
      headers: { Accept: "application/json", "Content-Type": "application/json" },
      body: action === "me" ? undefined : JSON.stringify(body ?? {}),
    });
  } catch {
    throw new ApiError(0, messageForStatus(0, ""));
  }

  return readEnvelope<T>(response);
}
