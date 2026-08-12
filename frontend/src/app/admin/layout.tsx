import type { ReactNode } from "react";
import Link from "next/link";
import { siteConfig } from "@/lib/config";

// Layout khu quan tri (rieng biet voi khu mua sam): sidebar + noi dung.
const menu = [
  { label: "Tổng quan", href: "/admin" },
  { label: "Danh mục", href: "/admin/categories" },
  { label: "Sản phẩm", href: "/admin/products" },
  { label: "Đơn hàng", href: "/admin/orders" },
];

export default function AdminLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen">
      {/* Sidebar */}
      <aside className="hidden w-60 shrink-0 border-r border-zinc-200 bg-white p-4 sm:block">
        <Link href="/" className="mb-6 flex items-center gap-2">
          <span className="grid h-8 w-8 place-items-center rounded-full bg-rose-500 text-white">
            🍼
          </span>
          <span className="font-bold">{siteConfig.shortName}</span>
        </Link>
        <nav className="space-y-1">
          {menu.map((m) => (
            <Link
              key={m.href}
              href={m.href}
              className="block rounded-lg px-3 py-2 text-sm text-zinc-600 hover:bg-zinc-100 hover:text-zinc-900"
            >
              {m.label}
            </Link>
          ))}
        </nav>
      </aside>

      {/* Noi dung */}
      <div className="flex-1">
        <header className="flex h-14 items-center justify-between border-b border-zinc-200 bg-white px-6">
          <span className="text-sm font-semibold text-zinc-700">
            Trang quản trị
          </span>
          <Link href="/" className="text-sm text-rose-600 hover:underline">
            ← Về trang chủ
          </Link>
        </header>
        <div className="p-6">{children}</div>
      </div>
    </div>
  );
}
