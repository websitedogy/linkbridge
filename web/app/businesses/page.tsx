import { Suspense } from "react";
import { BusinessesExplorer } from "@/features/businesses/businesses-explorer";

export default function BusinessesPage() {
  return (
    <Suspense fallback={<p>Loading businesses…</p>}>
      <BusinessesExplorer />
    </Suspense>
  );
}
