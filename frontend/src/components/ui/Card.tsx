import { cn } from "@/lib/cn";
import type { ReactNode } from "react";

// The card don gian, dung cho danh sach/khu vuc noi dung.
export function Card({
  className,
  children,
}: {
  className?: string;
  children: ReactNode;
}) {
  return (
    <div
      className={cn(
        "rounded-2xl border border-zinc-200 bg-white p-5 shadow-sm",
        className
      )}
    >
      {children}
    </div>
  );
}
