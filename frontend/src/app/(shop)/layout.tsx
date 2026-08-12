import type { ReactNode } from "react";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";

// Layout cho khu vuc mua sam (cong khai): co Header + Footer.
export default function ShopLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />
      <main className="flex-1 py-8">{children}</main>
      <Footer />
    </div>
  );
}
