"use client";

import { usePathname } from "next/navigation";
import { BottomNav } from "@/components/bottom-nav";
import { ChatWidget } from "@/features/assistant/chat-widget";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  if (pathname === "/") {
    return (
      <div className="min-h-full flex-1 bg-[#F7F8F6] pb-24 text-[#1A1F1C] md:pb-0">
        {children}
        <SiteFooter />
        <ChatWidget />
        <BottomNav />
      </div>
    );
  }

  return (
    <>
      <SiteHeader />
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 pt-8 pb-28 md:pb-16">{children}</main>
      <SiteFooter />
      <ChatWidget />
      <BottomNav />
    </>
  );
}
