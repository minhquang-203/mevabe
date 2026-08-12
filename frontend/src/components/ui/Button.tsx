import { cn } from "@/lib/cn";
import Link from "next/link";
import type { ComponentProps, ReactNode } from "react";

type Variant = "primary" | "secondary" | "ghost";
type Size = "sm" | "md";

const base =
  "inline-flex items-center justify-center gap-2 rounded-full font-medium transition-colors disabled:opacity-50 disabled:pointer-events-none";

const variants: Record<Variant, string> = {
  primary: "bg-rose-500 text-white hover:bg-rose-600",
  secondary: "bg-white text-zinc-900 border border-zinc-200 hover:bg-zinc-50",
  ghost: "text-zinc-700 hover:bg-zinc-100",
};

const sizes: Record<Size, string> = {
  sm: "h-9 px-4 text-sm",
  md: "h-11 px-6 text-sm",
};

function classes(variant: Variant, size: Size, className?: string) {
  return cn(base, variants[variant], sizes[size], className);
}

// Nut dang <button>
export function Button({
  variant = "primary",
  size = "md",
  className,
  children,
  ...props
}: {
  variant?: Variant;
  size?: Size;
} & ComponentProps<"button">) {
  return (
    <button className={classes(variant, size, className)} {...props}>
      {children}
    </button>
  );
}

// Nut dang lien ket (dieu huong)
export function ButtonLink({
  href,
  variant = "primary",
  size = "md",
  className,
  children,
}: {
  href: string;
  variant?: Variant;
  size?: Size;
  className?: string;
  children: ReactNode;
}) {
  return (
    <Link href={href} className={classes(variant, size, className)}>
      {children}
    </Link>
  );
}
