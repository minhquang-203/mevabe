import { cn } from "@/lib/cn";
import type { ReactNode } from "react";

// Khung gioi han chieu rong noi dung, can giua trang.
export function Container({
  className,
  children,
}: {
  className?: string;
  children: ReactNode;
}) {
  return (
    <div className={cn("mx-auto w-full max-w-6xl px-4 sm:px-6", className)}>
      {children}
    </div>
  );
}
