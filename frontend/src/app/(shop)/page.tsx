import { Container } from "@/components/ui/Container";
import { Card } from "@/components/ui/Card";
import { ButtonLink } from "@/components/ui/Button";
import { siteConfig } from "@/lib/config";

const features = [
  {
    icon: "🍼",
    title: "Sữa & Dinh dưỡng",
    desc: "Sữa công thức, ăn dặm, vitamin cho bé và mẹ.",
  },
  {
    icon: "🧷",
    title: "Bỉm & Đồ sơ sinh",
    desc: "Bỉm tã, quần áo, đồ dùng cho bé mới sinh.",
  },
  {
    icon: "🧸",
    title: "Đồ chơi & Thời trang",
    desc: "Đồ chơi an toàn, thời trang cho bé theo độ tuổi.",
  },
];

export default function HomePage() {
  return (
    <Container className="space-y-12">
      {/* Hero */}
      <section className="overflow-hidden rounded-3xl bg-gradient-to-br from-rose-50 to-sky-50 p-8 sm:p-14">
        <div className="max-w-2xl">
          <span className="inline-flex items-center rounded-full bg-white px-3 py-1 text-xs font-medium text-rose-600 shadow-sm">
            Website bán hàng Mẹ &amp; Bé
          </span>
          <h1 className="mt-4 text-4xl font-bold leading-tight tracking-tight text-zinc-900 sm:text-5xl">
            Chăm sóc mẹ &amp; bé <br /> trọn vẹn từng ngày
          </h1>
          <p className="mt-4 text-lg text-zinc-600">
            {siteConfig.description}
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <ButtonLink href="/categories">Khám phá danh mục</ButtonLink>
            <ButtonLink href="/products" variant="secondary">
              Xem sản phẩm
            </ButtonLink>
          </div>
        </div>
      </section>

      {/* Feature cards */}
      <section className="grid gap-5 sm:grid-cols-3">
        {features.map((f) => (
          <Card key={f.title}>
            <div className="text-3xl">{f.icon}</div>
            <h3 className="mt-3 text-lg font-semibold text-zinc-900">
              {f.title}
            </h3>
            <p className="mt-1 text-sm text-zinc-500">{f.desc}</p>
          </Card>
        ))}
      </section>

      {/* Trang thai ket noi backend */}
      <section className="rounded-2xl border border-zinc-200 bg-white p-6">
        <h2 className="text-lg font-semibold text-zinc-900">
          Kết nối hệ thống
        </h2>
        <p className="mt-1 text-sm text-zinc-500">
          Frontend này gọi trực tiếp API của backend Spring Boot.
        </p>
        <div className="mt-4 flex flex-wrap gap-3 text-sm">
          <a
            className="text-rose-600 hover:underline"
            href="http://localhost:8080/api/swagger-ui.html"
            target="_blank"
            rel="noreferrer"
          >
            → Tài liệu API (Swagger)
          </a>
          <a
            className="text-rose-600 hover:underline"
            href="http://localhost:8080/api/actuator/health"
            target="_blank"
            rel="noreferrer"
          >
            → Health check
          </a>
        </div>
      </section>
    </Container>
  );
}
