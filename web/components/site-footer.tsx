import Link from "next/link";

const footerLinks = [
  {
    title: "Marketplace",
    links: [
      { label: "Browse businesses", href: "/buy" },
      { label: "Sell a business", href: "/sale" },
      { label: "Company search", href: "/cin-verify" },
    ],
  },
  {
    title: "Get started",
    links: [
      { label: "Create an account", href: "/register" },
      { label: "Log in", href: "/login" },
      { label: "Licences", href: "/licences" },
    ],
  },
] as const;

export function SiteFooter() {
  return (
    <footer className="mt-auto bg-[#14243A] text-white">
      <div className="mx-auto grid max-w-6xl gap-10 px-4 py-12 md:grid-cols-[1.5fr_1fr_1fr] md:px-6 md:py-14">
        <div className="max-w-sm">
          <Link href="/" className="text-xl font-bold tracking-tight">
            LinksBridge
          </Link>
          <p className="mt-3 text-sm leading-6 text-white/70">
            A simpler way to discover business opportunities and make your next move.
          </p>
        </div>

        {footerLinks.map((group) => (
          <nav key={group.title} aria-label={group.title}>
            <h2 className="text-sm font-semibold">{group.title}</h2>
            <ul className="mt-4 space-y-3">
              {group.links.map((link) => (
                <li key={link.href}>
                  <Link
                    href={link.href}
                    className="text-sm text-white/70 transition-colors hover:text-white"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </nav>
        ))}
      </div>
      <div className="border-t border-white/15">
        <div className="mx-auto flex max-w-6xl flex-col gap-2 px-4 py-5 text-xs text-white/60 sm:flex-row sm:items-center sm:justify-between md:px-6">
          <p>© {new Date().getFullYear()} LinksBridge. All rights reserved.</p>
          <p>Connecting businesses with their next opportunity.</p>
        </div>
      </div>
    </footer>
  );
}
