"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function CompaniesPage() {
  const companies = useQuery({ queryKey: ["companies"], queryFn: marketplace.companies });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-semibold">Companies</h1>
        <Link href="/seller/companies/create" className="rounded-md bg-zinc-900 px-3 py-2 text-sm text-white">
          Create company
        </Link>
      </div>
      <ErrorBanner error={companies.error} />
      <ul className="space-y-3">
        {companies.data?.map((company) => (
          <li key={company.id} className="rounded-lg border border-zinc-200 bg-white p-4">
            <p className="font-medium">{company.public_name}</p>
            <p className="text-sm text-zinc-600">
              Legal name is kept private: {company.company_name}
            </p>
            <p className="text-sm text-zinc-500">
              {[company.industry, company.city].filter(Boolean).join(" · ")} · {company.verification_status}
            </p>
          </li>
        ))}
      </ul>
    </div>
  );
}
