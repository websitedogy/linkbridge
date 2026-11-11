"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const items = [
  { href: "/buy", label: "Buy", icon: "buy" },
  { href: "/sale", label: "Sell", icon: "sell" },
  { href: "/cin-verify", label: "Search", icon: "search" },
  { href: "/profile", label: "Account", icon: "profile" },
] as const;

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed inset-x-0 bottom-0 z-30 border-t border-[#E5E7EB] bg-white md:hidden">
      <ul className="mx-auto grid max-w-3xl grid-cols-4 px-1 pt-2 pb-[max(0.45rem,env(safe-area-inset-bottom))] text-center">
        {items.map((item) => {
          const active = isActive(pathname, item.href);
          return (
            <li key={item.href}>
              <Link
                href={item.href}
                className={`flex flex-col items-center gap-1 pb-1 text-[11px] font-medium ${active ? "text-[#1764F5]" : "text-[#6B7280]"}`}
              >
                <NavIcon name={item.icon} />
                {item.label}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}

function isActive(pathname: string, href: string) {
  if (href === "/") return pathname === "/";
  return pathname === href || pathname.startsWith(`${href}/`);
}

function NavIcon({ name }: { name: string }) {
  const common = {
    width: 22,
    height: 22,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    "aria-hidden": true as const,
  };

  if (name === "sell") {
    return (
      <svg {...common}>
        <path d="M4 8h16v11a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1z" />
        <path d="M8 8V6a4 4 0 0 1 8 0v2M12 12v4M10 14h4" />
      </svg>
    );
  }
  if (name === "search") {
    return (
      <svg {...common}>
        <circle cx="11" cy="11" r="6.5" />
        <path d="M16 16.5 20 20.5" />
      </svg>
    );
  }
  if (name === "buy") {
    return (
      <svg {...common}>
        <path d="M6 8h12l-1 12H7L6 8z" />
        <path d="M9 8V7a3 3 0 0 1 6 0v1" />
      </svg>
    );
  }
  return (
    <svg {...common}>
      <circle cx="12" cy="8" r="3" />
      <path d="M5.5 19a6.5 6.5 0 0 1 13 0" />
    </svg>
  );
}
