import { Container } from "@/components/ui/Container";
import { siteConfig } from "@/lib/config";

export function Footer() {
  return (
    <footer className="mt-auto border-t border-zinc-200 bg-white">
      <Container className="flex flex-col items-center justify-between gap-2 py-6 text-sm text-zinc-500 sm:flex-row">
        <p>
          © {new Date().getFullYear()} {siteConfig.name}
        </p>
        <p>Xây dựng với Next.js + Spring Boot</p>
      </Container>
    </footer>
  );
}
