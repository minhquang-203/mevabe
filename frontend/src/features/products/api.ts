import { apiFetch } from "@/lib/api";
import type { PageResponse, Product } from "@/lib/types";

/**
 * MAU client cho module products (backend chua lam).
 * Khi tao xong controller /v1/products o backend, cac ham nay chay duoc ngay.
 */

export function listProducts(params?: {
  keyword?: string;
  page?: number;
  size?: number;
}): Promise<PageResponse<Product>> {
  const query = new URLSearchParams();
  if (params?.keyword) query.set("keyword", params.keyword);
  if (params?.page !== undefined) query.set("page", String(params.page));
  if (params?.size !== undefined) query.set("size", String(params.size));

  const qs = query.toString();
  return apiFetch<PageResponse<Product>>(`/v1/products${qs ? `?${qs}` : ""}`);
}

export function getProduct(code: string): Promise<Product> {
  return apiFetch<Product>(`/v1/products/${code}`);
}
