"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { useSession } from "@/features/auth/use-session";

const companyTypes = [
  {
    name: "LLP",
    count: "2 for sale",
    keyword: "LLP",
    tone: "bg-blue-50 text-blue-800",
  },
  {
    name: "Pvt Ltd",
    count: "2 for sale",
    keyword: "Pvt Ltd",
    tone: "bg-emerald-50 text-emerald-800",
  },
  {
    name: "OPC",
    count: "2 for sale",
    keyword: "OPC",
    tone: "bg-orange-50 text-orange-800",
  },
  {
    name: "Section 8",
    count: "2 for sale",
    keyword: "Section 8",
    tone: "bg-violet-50 text-violet-800",
  },
  {
    name: "Nidhi Company",
    count: "1 for sale",
    keyword: "Nidhi",
    tone: "bg-rose-50 text-rose-800",
  },
  {
    name: "Producer Company",
    count: "2 for sale",
    keyword: "Producer",
    tone: "bg-sky-50 text-sky-800",
  },
] as const;

const featured = [
  {
    title: "Established IT Services Company",
    location: "Hyderabad, India",
    badge: "PALM",
    description:
      "A profitable IT services company with strong client base and recurring revenue.",
    price: "₹15 - 30 Cr",
    revenue: "₹5 - 7 Cr",
    image:
      "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=900&q=80",
  },
  {
    title: "Precision Engineering Company",
    location: "Pune, India",
    badge: "Manufacturing",
    description: "Well-established manufacturing business with global clients.",
    price: "₹25 - 30 Cr",
    revenue: "₹10 - 12 Cr",
    image:
      "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=900&q=80",
  },
  {
    title: "Premium Retail Brand",
    location: "Bengaluru, India",
    badge: "Retail",
    description:
      "Multi-outlet retail brand with a loyal customer base and steady revenue.",
    price: "₹10 - 15 Cr",
    revenue: "₹6 - 8 Cr",
    image:
      "https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=900&q=80",
  },
] as const;

const recent = [
  {
    title: "Multi-Specialty Clinic",
    location: "Chennai, India",
    image:
      "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=700&q=80",
  },
  {
    title: "Construction Services Business",
    location: "Hyderabad, India",
    image:
      "https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=700&q=80",
  },
  {
    title: "City Logistics Pvt Ltd",
    location: "Bengaluru, India",
    image:
      "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=700&q=80",
  },
  {
    title: "Dairy Producer Company",
    location: "Warangal, India",
    image:
      "https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=700&q=80",
  },
] as const;

const industries = [
  "Technology",
  "Manufacturing",
  "Retail",
  "Healthcare",
  "Construction",
];

export function HomeScreen() {
  const router = useRouter();
  const session = useSession();
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [notice, setNotice] = useState("");
  const [saved, setSaved] = useState<string[]>([]);

  function search(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const keyword = String(formData.get("keyword") ?? "").trim();
    const location = String(formData.get("location") ?? "").trim();
    const query = [
      keyword,
      location && location !== "All India" ? location : "",
    ]
      .filter(Boolean)
      .join(" ");
    router.push(query ? `/buy?keyword=${encodeURIComponent(query)}` : "/buy");
  }

  function toggleSaved(title: string) {
    setSaved((current) =>
      current.includes(title)
        ? current.filter((item) => item !== title)
        : [...current, title],
    );
  }

  return (
    <div className="min-h-dvh bg-[#F7F9FC] text-[#15243A]">
      <header className="sticky top-0 z-30 border-b border-[#E7EBF1] bg-white/95 backdrop-blur">
        <div className="mx-auto flex h-14 max-w-6xl items-center gap-2 px-3 sm:gap-4 md:px-6">
          <button
            type="button"
            className="flex h-9 w-9 items-center justify-center rounded-lg text-[#334155] sm:hidden"
            aria-label={mobileMenuOpen ? "Close navigation" : "Open navigation"}
            aria-expanded={mobileMenuOpen}
            onClick={() => setMobileMenuOpen((open) => !open)}
          >
            <MenuIcon open={mobileMenuOpen} />
          </button>
          <Link
            href="/"
            className="flex shrink-0 items-center gap-1.5 text-[16px] font-bold tracking-tight"
          >
            <span className="flex h-7 w-7 items-center justify-center rounded-[7px] bg-[#1764F5] text-[19px] font-extrabold leading-none text-white">
              B
            </span>
            <span>LinksBridge</span>
          </Link>
          <nav className="ml-6 hidden items-center gap-7 text-xs font-semibold text-[#536174] sm:flex md:ml-8">
            <Link
              href="/buy"
              className="transition-colors hover:text-[#1764F5]"
            >
              Buy
            </Link>
            <Link
              href="/sale"
              className="transition-colors hover:text-[#1764F5]"
            >
              Sell
            </Link>
            <Link
              href="/cin-verify"
              className="transition-colors hover:text-[#1764F5]"
            >
              Search
            </Link>
          </nav>
          <div className="ml-auto flex items-center gap-2 md:gap-4">
            <button
              type="button"
              aria-label="Notifications"
              onClick={() => setNotice("No new notifications")}
              className="relative rounded-full p-1.5 text-[#334155] transition-colors hover:bg-[#F1F5F9] sm:p-2"
            >
              <BellIcon />
              <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full border border-white bg-[#EF4444]" />
            </button>
            <details className="group relative">
              <summary className="flex cursor-pointer list-none items-center gap-1.5 rounded-full border border-[#E7EBF1] py-0.5 pr-1.5 pl-0.5 transition-colors hover:bg-[#F8FAFC] sm:gap-2 sm:py-1 sm:pr-2 sm:pl-1">
                <span className="flex h-6 w-6 items-center justify-center overflow-hidden rounded-full bg-[#DCE8FF] text-[11px] font-bold text-[#1764F5] sm:h-7 sm:w-7 sm:text-xs">
                  {initials(session.data?.name)}
                </span>
                <span className="hidden text-xs font-medium sm:inline">
                  {session.data?.name ?? "Account"}
                </span>
                <ChevronDownIcon />
              </summary>
              <div className="absolute right-0 z-40 mt-2 w-44 overflow-hidden rounded-xl border border-[#E7EBF1] bg-white py-1 text-sm shadow-xl">
                {session.data ? (
                  <Link
                    href="/profile"
                    className="block px-4 py-2.5 text-[#334155] hover:bg-[#F1F5F9]"
                  >
                    Profile
                  </Link>
                ) : (
                  <>
                    <Link
                      href="/login"
                      className="block px-4 py-2.5 text-[#334155] hover:bg-[#F1F5F9]"
                    >
                      Log in
                    </Link>
                    <Link
                      href="/register"
                      className="block px-4 py-2.5 text-[#334155] hover:bg-[#F1F5F9]"
                    >
                      Create an account
                    </Link>
                  </>
                )}
              </div>
            </details>
          </div>
        </div>
        {mobileMenuOpen ? (
          <nav className="absolute inset-x-0 top-full border-b border-[#E7EBF1] bg-white p-3 shadow-lg sm:hidden">
            {[
              { label: "Buy a business", href: "/buy" },
              { label: "Sell a business", href: "/sale" },
              { label: "Company search", href: "/cin-verify" },
            ].map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setMobileMenuOpen(false)}
                className="block rounded-xl px-4 py-3 text-sm font-medium text-[#334155] hover:bg-[#F1F5F9]"
              >
                {item.label}
              </Link>
            ))}
          </nav>
        ) : null}
      </header>

      {notice ? (
        <p className="bg-[#153C83] px-4 py-2 text-center text-sm text-white">
          {notice}
        </p>
      ) : null}
      <section className="relative isolate overflow-hidden bg-[#EAF1FC]">
        <div
          className="absolute inset-0 -z-20 bg-cover bg-[center_42%]"
          style={{
            backgroundImage: "url('/link_logo.png')",
          }}
        />
        <div className="absolute inset-0 -z-10 bg-gradient-to-r from-white/65 via-white/50 to-[#123D81]/35 md:via-white/40 md:to-[#0C3477]/45" />
        <div className="mx-auto grid max-w-6xl grid-cols-1 items-center gap-5 px-4 pt-6 pb-5 md:min-h-[340px] md:grid-cols-[0.92fr_1.08fr] md:gap-8 md:px-6 md:py-8">
          <div className="relative z-10 translate-x-2 md:translate-x-4">
            <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-[#1764F5] md:text-xs">
              Businesses · Opportunities · Growth
            </p>
            <h1 className="mt-2 max-w-xl text-[34px] leading-[1.04] font-extrabold tracking-tight text-[#14243A] sm:text-[42px] md:text-[48px]">
              Buy &amp; Sell
              <span className="block text-[#1764F5]">Companies</span>
            </h1>
            <p className="mt-2 max-w-md text-[13px] leading-5 text-[#536174] md:mt-3 md:text-[15px] md:leading-6">
              Find the right business opportunity or list your company with
              trusted buyers and sellers across India.
            </p>
            <div className="mt-4 flex flex-wrap gap-2">
              <Link
                href="/buy"
                className="inline-flex min-h-10 items-center justify-center gap-2 rounded-xl bg-[#1764F5] px-4 text-xs font-semibold text-white shadow-[0_5px_14px_rgba(23,100,245,0.2)] transition-colors hover:bg-[#0E54DB] sm:text-sm"
              >
                <BuildingIcon />
                Buy a Business
                <ArrowRightIcon />
              </Link>
              <Link
                href="/sale"
                className="inline-flex min-h-10 items-center justify-center gap-2 rounded-xl border border-[#D9E1EC] bg-white/95 px-4 text-xs font-semibold text-[#26364B] transition-colors hover:border-[#1764F5] hover:text-[#1764F5] sm:text-sm"
              >
                <TagIcon />
                Sell a Business
                <ArrowRightIcon />
              </Link>
            </div>
            <div className="mt-4 hidden items-center gap-5 sm:flex md:mt-5">
              <TrustItem
                icon="shield"
                title="Verified Listings"
                detail="Genuine businesses"
              />
              <TrustItem
                icon="chart"
                title="Wide Network"
                detail="Serious buyers & sellers"
              />
              <TrustItem
                icon="globe"
                title="Multiple Industries"
                detail="Across India"
              />
            </div>
          </div>

          <form
            onSubmit={search}
            className="relative z-10 rounded-2xl border border-white/80 bg-white/95 p-2 shadow-[0_12px_36px_rgba(17,43,82,0.2)] backdrop-blur md:absolute md:right-[max(calc((100vw-72rem)/2+1.5rem),1.5rem)] md:bottom-7 md:flex md:w-[min(55%,42rem)] md:items-center md:gap-2 md:p-3"
          >
            <label className="flex h-11 min-w-0 flex-1 items-center gap-2 rounded-xl border border-[#E2E8F0] px-3 focus-within:border-[#1764F5] md:h-12">
              <SearchIcon />
              <input
                name="keyword"
                placeholder="Search companies, industry, location..."
                className="min-w-0 flex-1 bg-transparent text-xs text-[#1A1F1C] outline-none placeholder:text-[#8290A3] md:text-sm"
              />
              <button
                type="button"
                aria-expanded={filtersOpen}
                aria-label="Filter by industry"
                onClick={() => setFiltersOpen((open) => !open)}
                className="rounded-md p-1.5 text-[#526176] transition-colors hover:bg-[#F1F5F9]"
              >
                <FilterIcon />
              </button>
            </label>
            <div className="mt-2 grid grid-cols-[1fr_auto] gap-2 md:mt-0 md:contents">
              <label className="flex h-10 items-center gap-2 rounded-xl border border-[#E2E8F0] px-3 text-xs text-[#536174] md:hidden">
                <GlobeIcon />
                <select
                  name="location"
                  defaultValue="All India"
                  aria-label="Choose location"
                  className="min-w-0 flex-1 appearance-none bg-transparent outline-none"
                >
                  <option>All India</option>
                  <option>Hyderabad</option>
                  <option>Bengaluru</option>
                  <option>Mumbai</option>
                  <option>Delhi</option>
                  <option>Chennai</option>
                  <option>Pune</option>
                </select>
                <ChevronDownIcon />
              </label>
              <button
                type="button"
                aria-expanded={filtersOpen}
                aria-label="Filter by industry"
                onClick={() => setFiltersOpen((open) => !open)}
                className="flex h-10 w-10 items-center justify-center rounded-xl border border-[#E2E8F0] text-[#526176] transition-colors hover:bg-[#F1F5F9] md:hidden"
              >
                <FilterIcon />
              </button>
            </div>
            <button
              type="submit"
              className="mt-2 flex h-10 w-full items-center justify-center gap-2 rounded-xl bg-[#1764F5] text-sm font-semibold text-white transition-colors hover:bg-[#0E54DB] md:mt-0 md:h-12 md:w-auto md:min-w-28 md:px-5"
            >
              <SearchIcon />
              Search
            </button>
          </form>
        </div>
      </section>

      <main className="mx-auto max-w-6xl px-4 pt-5 pb-8 md:px-6 md:pt-7 md:pb-12">
        <div className="grid grid-cols-4 gap-2 rounded-2xl border border-[#E9EEF5] bg-white px-2 py-3 shadow-[0_4px_16px_rgba(25,48,82,0.04)] sm:grid-cols-4 md:hidden">
          <TrustItem icon="shield" title="Verified" detail="Listings" compact />
          <TrustItem icon="chart" title="Wide" detail="Network" compact />
          <TrustItem
            icon="globe"
            title="Multiple"
            detail="Industries"
            compact
          />
          <TrustItem icon="support" title="Expert" detail="Support" compact />
        </div>

        {filtersOpen ? (
          <div className="mt-3 flex flex-wrap gap-2 rounded-2xl border border-[#E9EEF5] bg-white p-3">
            {industries.map((industry) => (
              <button
                key={industry}
                type="button"
                onClick={() =>
                  router.push(`/buy?keyword=${encodeURIComponent(industry)}`)
                }
                className="rounded-full border border-[#E2E8F0] bg-[#F8FAFC] px-3 py-1.5 text-xs font-medium text-[#334155] transition-colors hover:border-[#1764F5] hover:text-[#1764F5]"
              >
                {industry}
              </button>
            ))}
          </div>
        ) : null}

        <section className="mt-5 md:mt-3">
          <SectionTitle
            title="Company Types"
            subtitle="Choose a business type to explore companies for sale."
            href="/buy"
          />
          <div className="mt-3 grid grid-cols-3 gap-1.5 min-[380px]:grid-cols-4 sm:grid-cols-3 sm:gap-2 md:grid-cols-6 md:gap-3">
            {companyTypes.map((type) => (
              <Link
                key={type.name}
                href={`/buy?keyword=${encodeURIComponent(type.keyword)}`}
                className="group flex min-h-[62px] min-w-0 items-center gap-2 rounded-xl border border-[#E9EEF5] bg-white p-2 shadow-[0_4px_14px_rgba(25,48,82,0.04)] transition-all hover:-translate-y-0.5 hover:border-[#C8D8F5] hover:shadow-md sm:gap-2.5 sm:p-2.5 md:min-h-[72px] md:gap-3 md:rounded-2xl md:p-3"
              >
                <span
                  className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-lg sm:h-9 sm:w-9 md:h-10 md:w-10 md:rounded-xl ${type.tone}`}
                >
                  <BuildingIcon />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block truncate text-[11px] font-bold text-[#26364B] sm:text-xs md:text-sm">
                    {type.name}
                  </span>
                  <span className="block text-[10px] text-[#8290A3] sm:text-[11px]">
                    {type.count}
                  </span>
                </span>
                <span className="hidden text-[#8EA0B7] transition-transform group-hover:translate-x-0.5 md:block">
                  <ArrowRightIcon />
                </span>
              </Link>
            ))}
          </div>
        </section>

        <section className="mt-6 md:mt-7">
          <SectionTitle
            title="Featured Companies"
            subtitle="Handpicked business opportunities from various industries."
            href="/buy"
          />
          <div className="mt-3 grid gap-3 sm:grid-cols-2 lg:grid-cols-3 md:gap-4">
            {featured.map((company) => (
              <article
                key={company.title}
                className="group overflow-hidden rounded-2xl border border-[#E9EEF5] bg-white shadow-[0_5px_20px_rgba(25,48,82,0.06)] transition-all hover:-translate-y-0.5 hover:shadow-lg"
              >
                <div className="relative h-36 overflow-hidden sm:h-40 md:h-36">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={company.image}
                    alt=""
                    className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-[1.03]"
                  />
                  <button
                    type="button"
                    aria-label={
                      saved.includes(company.title)
                        ? "Remove saved"
                        : "Save company"
                    }
                    onClick={() => toggleSaved(company.title)}
                    className="absolute top-2 right-2 flex h-8 w-8 items-center justify-center rounded-full border border-[#E7EBF1] bg-white/95 text-lg text-[#E11D48] shadow-sm transition-transform hover:scale-105"
                  >
                    {saved.includes(company.title) ? "♥" : "♡"}
                  </button>
                </div>
                <div className="p-3.5 md:p-3">
                  <span className="inline-flex rounded-full bg-[#E8F6EE] px-2 py-0.5 text-[10px] font-bold text-[#1B7A45]">
                    {company.badge}
                  </span>
                  <h3 className="mt-1.5 text-sm font-bold text-[#203149]">
                    <Link
                      href={`/buy?keyword=${encodeURIComponent(company.title)}`}
                    >
                      {company.title}
                    </Link>
                  </h3>
                  <p className="mt-1 flex items-center gap-1 text-[11px] text-[#64748B]">
                    <PinIcon />
                    {company.location}
                  </p>
                  <p className="mt-1.5 line-clamp-2 text-xs leading-[1.45] text-[#64748B]">
                    {company.description}
                  </p>
                  <dl className="mt-3 grid grid-cols-2 gap-2 border-t border-[#EEF1F5] pt-2.5 text-xs">
                    <div>
                      <dt className="text-[10px] text-[#8290A3]">
                        Asking Price
                      </dt>
                      <dd className="mt-0.5 font-bold text-[#26364B]">
                        {company.price}
                      </dd>
                    </div>
                    <div>
                      <dt className="text-[10px] text-[#8290A3]">
                        Annual Revenue
                      </dt>
                      <dd className="mt-0.5 font-bold text-[#26364B]">
                        {company.revenue}
                      </dd>
                    </div>
                  </dl>
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="mt-6 md:mt-7">
          <SectionTitle
            title="Recently Added"
            subtitle="Latest business opportunities added to the platform."
            href="/buy"
          />
          <div className="mt-3 flex snap-x gap-3 overflow-x-auto pb-2 sm:grid sm:grid-cols-2 lg:grid-cols-4">
            {recent.map((company) => (
              <Link
                key={company.title}
                href={`/buy?keyword=${encodeURIComponent(company.title)}`}
                className="w-[72%] shrink-0 snap-start overflow-hidden rounded-2xl border border-[#E9EEF5] bg-white shadow-[0_5px_20px_rgba(25,48,82,0.05)] transition-shadow hover:shadow-md sm:w-auto"
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={company.image}
                  alt=""
                  className="h-28 w-full object-cover sm:h-32"
                />
                <span className="block p-3">
                  <span className="block line-clamp-2 text-xs font-bold text-[#26364B]">
                    {company.title}
                  </span>
                  <span className="mt-1 flex items-center gap-1 truncate text-[11px] text-[#64748B]">
                    <PinIcon />
                    {company.location}
                  </span>
                </span>
              </Link>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}

function SectionTitle({
  title,
  subtitle,
  href,
}: {
  title: string;
  subtitle: string;
  href: string;
}) {
  return (
    <div className="flex items-center justify-between gap-3">
      <div className="min-w-0">
        <h2 className="text-base font-bold tracking-tight text-[#203149] md:text-lg">
          {title}
        </h2>
        <p className="mt-0.5 text-[11px] text-[#718096] md:text-xs">
          {subtitle}
        </p>
      </div>
      <Link
        href={href}
        className="inline-flex shrink-0 items-center gap-1 text-xs font-semibold text-[#1764F5] transition-colors hover:text-[#0E54DB] md:text-sm"
      >
        View All <ArrowRightIcon />
      </Link>
    </div>
  );
}

function TrustItem({
  icon,
  title,
  detail,
  compact = false,
}: {
  icon: "shield" | "chart" | "globe" | "support";
  title: string;
  detail: string;
  compact?: boolean;
}) {
  return (
    <div
      className={`flex min-w-0 items-center ${compact ? "flex-col justify-center gap-1 text-center" : "gap-2"}`}
    >
      <span
        className={`shrink-0 text-[#1764F5] ${compact ? "[&_svg]:h-5 [&_svg]:w-5" : "[&_svg]:h-5 [&_svg]:w-5"}`}
      >
        {icon === "shield" ? <ShieldIcon /> : null}
        {icon === "chart" ? <ChartIcon /> : null}
        {icon === "globe" ? <GlobeIcon /> : null}
        {icon === "support" ? <SupportIcon /> : null}
      </span>
      <span className={compact ? "min-w-0" : ""}>
        <span
          className={`block font-semibold text-[#26364B] ${compact ? "text-[9px] leading-tight" : "text-[10px]"}`}
        >
          {title}
        </span>
        <span
          className={`block text-[#718096] ${compact ? "text-[9px] leading-tight" : "text-[9px]"}`}
        >
          {detail}
        </span>
      </span>
    </div>
  );
}

function initials(name?: string) {
  if (!name) return "A";
  const parts = name.trim().split(/\s+/);
  return `${parts[0]?.[0] ?? ""}${parts[1]?.[0] ?? ""}`.toUpperCase() || "A";
}

function BellIcon() {
  return (
    <svg
      width="22"
      height="22"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M6 9a6 6 0 1 1 12 0c0 7 2 7 2 7H4s2 0 2-7" />
      <path d="M10 19a2 2 0 0 0 4 0" />
    </svg>
  );
}

function SearchIcon() {
  return (
    <svg
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      aria-hidden="true"
    >
      <circle cx="11" cy="11" r="6.5" />
      <path d="M16 16.5 20 20.5" />
    </svg>
  );
}

function FilterIcon() {
  return (
    <svg
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M4 6h16M7 12h10M10 18h4" />
    </svg>
  );
}

function BuildingIcon() {
  return (
    <svg
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M4 20h16M6 20V6.5A1.5 1.5 0 0 1 7.5 5h5A1.5 1.5 0 0 1 14 6.5V20M14 10h3.5A1.5 1.5 0 0 1 19 11.5V20" />
      <path d="M8.5 8h2M8.5 11.5h2M8.5 15h2" />
    </svg>
  );
}

function MenuIcon({ open }: { open: boolean }) {
  return open ? (
    <svg
      width="21"
      height="21"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="m6 6 12 12M18 6 6 18" />
    </svg>
  ) : (
    <svg
      width="21"
      height="21"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M4 7h16M4 12h16M4 17h16" />
    </svg>
  );
}

function ChevronDownIcon() {
  return (
    <svg
      width="13"
      height="13"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="m7 10 5 5 5-5" />
    </svg>
  );
}

function ArrowRightIcon() {
  return (
    <svg
      width="15"
      height="15"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M5 12h14M13 6l6 6-6 6" />
    </svg>
  );
}

function TagIcon() {
  return (
    <svg
      width="17"
      height="17"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M20.6 13.4 13.4 20.6a2 2 0 0 1-2.8 0L3.4 13.4a2 2 0 0 1 0-2.8l7.2-7.2a2 2 0 0 1 1.4-.6H19a2 2 0 0 1 2 2v7a2 2 0 0 1-.4 1.6Z" />
      <circle cx="16.5" cy="7.5" r="1" />
    </svg>
  );
}

function PinIcon() {
  return (
    <svg
      className="h-3 w-3 shrink-0"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M20 10c0 5-8 12-8 12S4 15 4 10a8 8 0 1 1 16 0Z" />
      <circle cx="12" cy="10" r="2.5" />
    </svg>
  );
}

function GlobeIcon() {
  return (
    <svg
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="9" />
      <path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18" />
    </svg>
  );
}

function ShieldIcon() {
  return (
    <svg
      width="21"
      height="21"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M12 22s8-4 8-11V5l-8-3-8 3v6c0 7 8 11 8 11Z" />
      <path d="m9 12 2 2 4-4" />
    </svg>
  );
}

function ChartIcon() {
  return (
    <svg
      width="21"
      height="21"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M3 20h18M6 17V9h4v8M14 17V4h4v13" />
    </svg>
  );
}

function SupportIcon() {
  return (
    <svg
      width="21"
      height="21"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      aria-hidden="true"
    >
      <path d="M4 13v-2a8 8 0 0 1 16 0v2M4 13H3a1 1 0 0 0-1 1v3a1 1 0 0 0 1 1h3v-5H4ZM20 13h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-3v-5h2ZM16 21h-4" />
    </svg>
  );
}
