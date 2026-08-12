import { Container } from "@/components/ui/Container";
import { PageHeader } from "@/components/ui/PageHeader";
import { Card } from "@/components/ui/Card";
import { Badge } from "@/components/ui/Badge";
import { listProducts } from "@/features/products/api";
import { formatVND } from "@/lib/format";
import type { Product } from "@/lib/types";

export const dynamic = "force-dynamic";
export const metadata = { title: "Sản phẩm" };

// Trang san pham: lay du lieu that tu backend (/api/v1/products).
export default async function ProductsPage() {
  let products: Product[] = [];
  let errorMessage: string | null = null;

  try {
    const page = await listProducts({ size: 50 });
    products = page.items;
  } catch (e) {
    errorMessage = e instanceof Error ? e.message : "Không kết nối được backend";
  }

  return (
    <Container className="space-y-6">
      <PageHeader
        title="Sản phẩm"
        description="Dữ liệu lấy trực tiếp từ backend qua GET /api/v1/products"
      />

      {errorMessage ? (
        <Card className="border-amber-300 bg-amber-50">
          <p className="font-semibold text-amber-800">Chưa gọi được backend.</p>
          <p className="mt-1 text-sm text-amber-700">Lỗi: {errorMessage}</p>
        </Card>
      ) : products.length === 0 ? (
        <Card>
          <p className="text-sm text-zinc-600">
            Kết nối backend OK nhưng chưa có sản phẩm nào. Hãy thêm sản phẩm qua
            Swagger (<code>POST /api/v1/products</code>) hoặc trang quản trị.
          </p>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {products.map((p) => (
            <Card key={p.productCode} className="flex flex-col gap-2">
              <div className="flex items-start justify-between gap-2">
                <p className="font-semibold text-zinc-900">{p.name}</p>
                {p.isFeatured && <Badge tone="rose">Nổi bật</Badge>}
              </div>
              <p className="text-xs text-zinc-400">SKU: {p.sku}</p>
              <div className="mt-auto flex items-end justify-between pt-2">
                <div>
                  {p.salePrice != null ? (
                    <>
                      <span className="text-lg font-bold text-rose-600">
                        {formatVND(p.salePrice)}
                      </span>
                      <span className="ml-2 text-sm text-zinc-400 line-through">
                        {formatVND(p.basePrice)}
                      </span>
                    </>
                  ) : (
                    <span className="text-lg font-bold text-zinc-900">
                      {formatVND(p.basePrice)}
                    </span>
                  )}
                </div>
                <Badge tone={p.isActive ? "green" : "gray"}>
                  {p.isActive ? "Đang bán" : "Ẩn"}
                </Badge>
              </div>
            </Card>
          ))}
        </div>
      )}
    </Container>
  );
}
