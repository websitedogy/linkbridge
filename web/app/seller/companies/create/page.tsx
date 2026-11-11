"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { FormEvent, useState } from "react";
import { ErrorBanner } from "@/components/error-banner";
import { marketplace } from "@/features/marketplace/api";

export default function CreateCompanyPage() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const industries = useQuery({ queryKey: ["industries"], queryFn: marketplace.industries });
  const categories = useQuery({ queryKey: ["categories"], queryFn: marketplace.categories });
  const cities = useQuery({ queryKey: ["cities"], queryFn: () => marketplace.locations("city") });
  const [industryId, setIndustryId] = useState("");
  const create = useMutation({
    mutationFn: (body: Record<string, unknown>) => marketplace.createCompany(body),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["companies"] });
      router.push("/seller/companies");
    },
  });

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    create.mutate({
      company_name: form.get("company_name"),
      public_name: form.get("public_name"),
      industry_id: form.get("industry_id"),
      category_id: form.get("category_id"),
      location_id: form.get("location_id") || null,
      business_type: form.get("business_type"),
      description: form.get("description"),
      employee_count: form.get("employee_count") ? Number(form.get("employee_count")) : null,
      financials: { value_mode: form.get("value_mode") },
    });
  }

  const visibleCategories = categories.data?.filter((category) => category.industry_id === industryId) ?? [];

  return (
    <form onSubmit={onSubmit} className="mx-auto max-w-2xl space-y-4 rounded-lg border border-zinc-200 bg-white p-6">
      <h1 className="text-2xl font-semibold">Create company</h1>
      <p className="text-sm text-zinc-600">The legal name is private. Buyers see the public name.</p>
      <Field name="company_name" label="Legal company name" required />
      <Field name="public_name" label="Public listing name" required />
      <label className="block text-sm">
        Industry
        <select
          name="industry_id"
          required
          className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2"
          value={industryId}
          onChange={(event) => setIndustryId(event.target.value)}
        >
          <option value="">Select an industry</option>
          {industries.data?.map((industry) => (
            <option key={industry.id} value={industry.id}>
              {industry.name}
            </option>
          ))}
        </select>
      </label>
      <label className="block text-sm">
        Category
        <select name="category_id" required className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2">
          <option value="">Select a category</option>
          {visibleCategories.map((category) => (
            <option key={category.id} value={category.id}>
              {category.name}
            </option>
          ))}
        </select>
      </label>
      <label className="block text-sm">
        City
        <select name="location_id" className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2">
          <option value="">Select a city</option>
          {cities.data?.map((city) => (
            <option key={city.id} value={city.id}>
              {city.name}
            </option>
          ))}
        </select>
      </label>
      <label className="block text-sm">
        Business type
        <select name="business_type" required className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2">
          <option value="share_sale">Share sale</option>
          <option value="asset_sale">Asset sale</option>
          <option value="franchise">Franchise</option>
          <option value="partnership_interest">Partnership interest</option>
          <option value="other">Other</option>
        </select>
      </label>
      <Field name="employee_count" label="Employees" type="number" />
      <label className="block text-sm">
        Financial visibility
        <select name="value_mode" className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" defaultValue="private">
          <option value="private">Private</option>
          <option value="range">Range</option>
          <option value="exact">Exact</option>
        </select>
      </label>
      <label className="block text-sm">
        Description
        <textarea name="description" className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" rows={4} />
      </label>
      <ErrorBanner error={create.error ?? industries.error ?? categories.error ?? cities.error} />
      <button className="rounded-md bg-zinc-900 px-4 py-2 text-white" type="submit" disabled={create.isPending}>
        Save company
      </button>
    </form>
  );
}

function Field({ name, label, type = "text", required = false }: { name: string; label: string; type?: string; required?: boolean }) {
  return (
    <label className="block text-sm">
      {label}
      <input name={name} type={type} required={required} className="mt-1 w-full rounded-md border border-zinc-300 px-3 py-2" />
    </label>
  );
}
