"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Container } from "@/components/ui/Container";
import { siteConfig } from "@/lib/config";
import { cn } from "@/lib/cn";

// Thanh dieu huong tren cung. Dung "use client" de biet trang hien tai (active).
export function Header() {
  const pathname = usePathname();

  return (
    <header className="sticky top-0 z-40 border-b border-zinc-200 bg-white/80 backdrop-blur">
      <Container className="flex h-16 items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <span className="grid h-9 w-9 place-items-center rounded-full bg-rose-500 text-white">
            🍼
          </span>
          <span className="text-lg font-bold text-zinc-900">
            {siteConfig.shortName}
          </span>
        </Link>

        <nav className="flex items-center gap-1">
          {siteConfig.nav.map((item) => {
            const active =
              item.href === "/"
                ? pathname === "/"
                : pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "rounded-full px-3 py-2 text-sm font-medium transition-colors",
                  active
                    ? "bg-rose-50 text-rose-600"
                    : "text-zinc-600 hover:bg-zinc-100 hover:text-zinc-900"
                )}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
      </Container>
    </header>
  );
}
