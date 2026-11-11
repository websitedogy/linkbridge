import { ApiError } from "@/lib/api/errors";

export function ErrorBanner({ error }: { error: unknown }) {
  if (!error) {
    return null;
  }

  const details = error instanceof ApiError && error.errors ? Object.values(error.errors).flat() : [];

  return (
    <div role="alert" className="rounded-md border border-red-300 bg-red-50 p-3 text-sm text-red-800">
      <p>{error instanceof Error ? error.message : "Something went wrong."}</p>
      {details.length > 0 ? (
        <ul className="mt-2 list-disc pl-5">
          {details.map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ul>
      ) : null}
    </div>
  );
}
