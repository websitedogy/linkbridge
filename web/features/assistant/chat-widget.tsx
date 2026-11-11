"use client";

import Link from "next/link";
import { FormEvent, useState } from "react";
import { apiRequest } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";

type ChatLink = { label: string; href: string };

type ChatMessage = {
  role: "user" | "assistant";
  text: string;
  links?: ChatLink[];
};

const greeting: ChatMessage = {
  role: "assistant",
  text: "Ask me about buying, selling, a CIN, or a city. I answer from the live marketplace.",
};

export function ChatWidget() {
  const [open, setOpen] = useState(false);
  const [draft, setDraft] = useState("");
  const [pending, setPending] = useState(false);
  const [messages, setMessages] = useState<ChatMessage[]>([greeting]);

  async function send(event: FormEvent) {
    event.preventDefault();
    const message = draft.trim();
    if (!message || pending) {
      return;
    }

    setDraft("");
    setMessages((current) => [...current, { role: "user", text: message }]);
    setPending(true);

    try {
      const response = await apiRequest<{ reply: string; links: ChatLink[] }>("/assistant", {
        method: "POST",
        body: { message },
      });
      setMessages((current) => [
        ...current,
        { role: "assistant", text: response.data.reply, links: response.data.links },
      ]);
    } catch (error) {
      const text = error instanceof ApiError ? error.message : "I could not reach the marketplace just now. Try again.";
      setMessages((current) => [...current, { role: "assistant", text }]);
    } finally {
      setPending(false);
    }
  }

  return (
    <div className="fixed right-4 bottom-24 z-40 flex flex-col items-end gap-3">
      {open ? (
        <section className="flex h-[28rem] max-h-[70vh] w-[min(22rem,calc(100vw-2rem))] flex-col overflow-hidden rounded-3xl bg-[#FBF8F1] text-[#1F2937] shadow-[0_16px_40px_rgba(31,41,55,0.2)]">
          <header className="flex items-center justify-between bg-[#0F3D2F] px-4 py-3 text-[#FBF8F1]">
            <div>
              <p className="text-sm font-semibold">LinksBridge</p>
              <p className="text-xs text-[#d4af37]">Marketplace assistant</p>
            </div>
            <button type="button" aria-label="Close chat" onClick={() => setOpen(false)} className="rounded-full px-2 py-1 text-lg leading-none">
              ×
            </button>
          </header>
          <div className="flex-1 space-y-3 overflow-y-auto px-4 py-4">
            {messages.map((message, index) => (
              <div key={`${message.role}-${index}`} className={message.role === "user" ? "ml-8" : "mr-6"}>
                <p
                  className={`rounded-2xl px-3 py-2 text-sm whitespace-pre-line ${
                    message.role === "user" ? "bg-[#0F3D2F] text-[#FBF8F1]" : "bg-white text-[#1F2937]"
                  }`}
                >
                  {message.text}
                </p>
                {message.links && message.links.length > 0 ? (
                  <div className="mt-2 flex flex-wrap gap-2">
                    {message.links.map((link) => (
                      <Link key={link.href + link.label} href={link.href} className="rounded-full bg-[#d4af37] px-3 py-1 text-xs font-semibold text-[#0F3D2F]">
                        {link.label}
                      </Link>
                    ))}
                  </div>
                ) : null}
              </div>
            ))}
            {pending ? <p className="text-xs text-[#1F2937]/50">Looking through the marketplace…</p> : null}
          </div>
          <form onSubmit={send} className="flex gap-2 border-t border-[#0F3D2F]/10 p-3">
            <input
              value={draft}
              onChange={(event) => setDraft(event.target.value)}
              placeholder="Ask about a business"
              className="min-w-0 flex-1 rounded-full border border-[#0F3D2F]/15 bg-white px-3 py-2 text-sm outline-none"
            />
            <button type="submit" disabled={pending} className="rounded-full bg-[#0F3D2F] px-3 py-2 text-sm font-semibold text-[#FBF8F1] disabled:opacity-50">
              Send
            </button>
          </form>
        </section>
      ) : null}
      <button
        type="button"
        aria-label={open ? "Close assistant" : "Open assistant"}
        aria-expanded={open}
        onClick={() => setOpen((value) => !value)}
        className="flex h-14 w-14 items-center justify-center rounded-full bg-[#0F3D2F] text-[#d4af37] shadow-[0_10px_24px_rgba(15,61,47,0.35)]"
      >
        <ChatIcon />
      </button>
    </div>
  );
}

function ChatIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true">
      <path d="M6 16.5 3.5 20V6.5A2.5 2.5 0 0 1 6 4h12a2.5 2.5 0 0 1 2.5 2.5v7.5A2.5 2.5 0 0 1 18 16.5z" />
      <path d="M8 9h8M8 12.5h5" />
    </svg>
  );
}
