"use client";

import Link from "next/link";
import { useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import { useLogout, useSession } from "@/features/auth/use-session";

export function SiteHeader() {
  const pathname = usePathname();
  const router = useRouter();
  const session = useSession();
  const logout = useLogout();
  const user = session.data;
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [notice, setNotice] = useState("");

  const navigation = [
    { label: "Buy", href: "/buy" },
    { label: "Sell", href: "/sale" },
    { label: "Search", href: "/cin-verify" },
  ];

  return (
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
          className="flex shrink-0 items-center gap-1.5 text-[16px] font-bold tracking-tight text-[#15243A]"
        >
          <span className="flex h-7 w-7 items-center justify-center rounded-[7px] bg-[#1764F5] text-[19px] font-extrabold leading-none text-white">
            B
          </span>
          <span>LinksBridge</span>
        </Link>
        <nav
          aria-label="Main navigation"
          className="ml-6 hidden items-center gap-7 text-xs font-semibold text-[#536174] sm:flex md:ml-8"
        >
          {navigation.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`transition-colors hover:text-[#1764F5] ${pathname.startsWith(item.href) ? "text-[#1764F5]" : ""}`}
            >
              {item.label}
            </Link>
          ))}
          {user?.role === "BUYER" ? (
            <Link
              href="/buyer/dashboard"
              className="transition-colors hover:text-[#1764F5]"
            >
              Buyer
            </Link>
          ) : null}
          {user?.role === "SELLER" ? (
            <Link
              href="/seller/dashboard"
              className="transition-colors hover:text-[#1764F5]"
            >
              Seller
            </Link>
          ) : null}
        </nav>
        <div className="ml-auto flex items-center gap-2">
          <button
            type="button"
            aria-label="Notifications"
            onClick={() =>
              setNotice((current) => (current ? "" : "No new notifications"))
            }
            className="relative rounded-full p-1.5 text-[#334155] transition-colors hover:bg-[#F1F5F9] sm:p-2"
          >
            <BellIcon />
            <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full border border-white bg-[#EF4444]" />
          </button>
          <details className="group relative">
            <summary className="flex cursor-pointer list-none items-center gap-1.5 rounded-full border border-[#E7EBF1] py-0.5 pr-1.5 pl-0.5 transition-colors hover:bg-[#F8FAFC] sm:gap-2 sm:py-1 sm:pr-2 sm:pl-1">
              <span className="flex h-6 w-6 items-center justify-center overflow-hidden rounded-full bg-[#DCE8FF] text-[11px] font-bold text-[#1764F5] sm:h-7 sm:w-7 sm:text-xs">
                {initials(user?.name)}
              </span>
              <span className="hidden text-xs font-medium text-[#26364B] sm:inline">
                {user?.name ?? "Account"}
              </span>
              <ChevronDownIcon />
            </summary>
            <div className="absolute right-0 z-40 mt-2 w-44 overflow-hidden rounded-xl border border-[#E7EBF1] bg-white py-1 text-sm shadow-xl">
              {user ? (
                <>
                  <Link
                    href="/profile"
                    className="block px-4 py-2.5 text-[#334155] hover:bg-[#F1F5F9]"
                  >
                    Profile
                  </Link>
                  <button
                    className="block w-full px-4 py-2.5 text-left text-[#334155] hover:bg-[#F1F5F9]"
                    type="button"
                    onClick={() =>
                      logout.mutate(undefined, {
                        onSuccess: () => router.push("/"),
                      })
                    }
                  >
                    Log out
                  </button>
                </>
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
        <nav
          aria-label="Mobile navigation"
          className="absolute inset-x-0 top-full border-b border-[#E7EBF1] bg-white p-3 shadow-lg sm:hidden"
        >
          {navigation.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileMenuOpen(false)}
              className="block rounded-xl px-4 py-3 text-sm font-medium text-[#334155] hover:bg-[#F1F5F9]"
            >
              {item.label === "Buy"
                ? "Buy a business"
                : item.label === "Sell"
                  ? "Sell a business"
                  : "Company search"}
            </Link>
          ))}
          {user?.role === "BUYER" ? (
            <Link
              href="/buyer/dashboard"
              className="block rounded-xl px-4 py-3 text-sm font-medium text-[#334155] hover:bg-[#F1F5F9]"
            >
              Buyer dashboard
            </Link>
          ) : null}
          {user?.role === "SELLER" ? (
            <Link
              href="/seller/dashboard"
              className="block rounded-xl px-4 py-3 text-sm font-medium text-[#334155] hover:bg-[#F1F5F9]"
            >
              Seller dashboard
            </Link>
          ) : null}
        </nav>
      ) : null}
      {notice ? (
        <p className="bg-[#153C83] px-4 py-2 text-center text-sm text-white">
          {notice}
        </p>
      ) : null}
    </header>
  );
}

function initials(name?: string) {
  if (!name) return "A";
  const parts = name.trim().split(/\s+/);
  return `${parts[0]?.[0] ?? ""}${parts[1]?.[0] ?? ""}`.toUpperCase() || "A";
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

function BellIcon() {
  return (
    <svg
      width="20"
      height="20"
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
