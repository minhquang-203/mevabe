import { cn } from "@/lib/cn";
import type { ReactNode } from "react";

type Tone = "green" | "gray" | "rose" | "amber";

const tones: Record<Tone, string> = {
  green: "bg-green-100 text-green-700",
  gray: "bg-zinc-100 text-zinc-600",
  rose: "bg-rose-100 text-rose-700",
  amber: "bg-amber-100 text-amber-800",
};

export function Badge({
  tone = "gray",
  className,
  children,
}: {
  tone?: Tone;
  className?: string;
  children: ReactNode;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium",
        tones[tone],
        className
      )}
    >
      {children}
    </span>
  );
}
