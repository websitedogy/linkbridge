import { Suspense } from "react";
import { BusinessesExplorer } from "@/features/businesses/businesses-explorer";

export default function SalePage() {
  return (
    <Suspense fallback={<p>Loading businesses for sale…</p>}>
      <BusinessesExplorer
        basePath="/sale"
        title="Businesses for sale"
        description="Published listings from the marketplace. Open one to see the public details."
      />
    </Suspense>
  );
}
