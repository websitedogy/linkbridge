import { Suspense } from "react";
import { BusinessesExplorer } from "@/features/businesses/businesses-explorer";

export default function BuyPage() {
  return (
    <Suspense fallback={<p>Loading businesses to buy…</p>}>
      <BusinessesExplorer
        basePath="/buy"
        title="Buy a business"
        description="Open a listing to save it or express interest. Sellers reply from their dashboard."
      />
    </Suspense>
  );
}
