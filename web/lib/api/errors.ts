export class ApiError extends Error {
  status: number;
  errors?: Record<string, string[]>;

  constructor(status: number, message: string, errors?: Record<string, string[]>) {
    super(message);
    this.status = status;
    this.errors = errors;
  }
}

export function messageForStatus(status: number, fallback: string): string {
  switch (status) {
    case 401:
      return "Your session has expired. Please sign in again.";
    case 403:
      return "You do not have permission to do that.";
    case 404:
      return "We could not find what you requested.";
    case 422:
      return fallback || "Please check the form and try again.";
    case 429:
      return "Too many attempts. Please wait a moment and try again.";
    case 0:
      return "Network error. Check your connection and try again.";
    default:
      return status >= 500 ? "Something went wrong on the server. Please try again." : fallback;
  }
}
