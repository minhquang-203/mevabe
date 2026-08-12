import { Container } from "@/components/ui/Container";
import { PageHeader } from "@/components/ui/PageHeader";
import { Card } from "@/components/ui/Card";
import { Badge } from "@/components/ui/Badge";
import { listCategories } from "@/features/categories/api";
import type { Category } from "@/lib/types";

export const dynamic = "force-dynamic";

export const metadata = { title: "Danh mục" };

// Trang danh muc: lay du lieu that tu backend (/api/v1/categories).
export default async function CategoriesPage() {
  let categories: Category[] = [];
  let errorMessage: string | null = null;

  try {
    const page = await listCategories({ size: 50 });
    categories = page.items;
  } catch (e) {
    errorMessage = e instanceof Error ? e.message : "Không kết nối được backend";
  }

  return (
    <Container className="space-y-6">
      <PageHeader
        title="Danh mục sản phẩm"
        description="Dữ liệu lấy trực tiếp từ backend qua GET /api/v1/categories"
      />

      {errorMessage ? (
        <Card className="border-amber-300 bg-amber-50">
          <p className="font-semibold text-amber-800">Chưa gọi được backend.</p>
          <p className="mt-1 text-sm text-amber-700">Lỗi: {errorMessage}</p>
          <p className="mt-2 text-sm text-amber-700">
            Hãy chắc chắn backend đang chạy ở http://localhost:8080 và MySQL đã
            bật (xem README).
          </p>
        </Card>
      ) : categories.length === 0 ? (
        <Card>
          <p className="text-sm text-zinc-600">
            Kết nối backend OK nhưng chưa có danh mục nào.
          </p>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {categories.map((c) => (
            <Card key={c.categoryCode} className="flex items-start justify-between">
              <div>
                <p className="font-semibold text-zinc-900">{c.name}</p>
                <p className="mt-1 text-xs text-zinc-400">
                  {c.categoryCode} · /{c.slug}
                </p>
              </div>
              <Badge tone={c.isActive ? "green" : "gray"}>
                {c.isActive ? "Đang bán" : "Ẩn"}
              </Badge>
            </Card>
          ))}
        </div>
      )}
    </Container>
  );
}
