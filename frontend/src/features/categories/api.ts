import { apiFetch } from "@/lib/api";
import type { Category, PageResponse } from "@/lib/types";

/**
 * Cac ham goi API cua module Category.
 * Moi module frontend nen co 1 file api.ts rieng nhu the nay (copy theo mau).
 */

export function listCategories(params?: {
  keyword?: string;
  isActive?: boolean;
  page?: number;
  size?: number;
}): Promise<PageResponse<Category>> {
  const query = new URLSearchParams();
  if (params?.keyword) query.set("keyword", params.keyword);
  if (params?.isActive !== undefined) query.set("isActive", String(params.isActive));
  if (params?.page !== undefined) query.set("page", String(params.page));
  if (params?.size !== undefined) query.set("size", String(params.size));

  const qs = query.toString();
  return apiFetch<PageResponse<Category>>(`/v1/categories${qs ? `?${qs}` : ""}`);
}

export function getCategory(code: string): Promise<Category> {
  return apiFetch<Category>(`/v1/categories/${code}`);
}

export function createCategory(payload: {
  name: string;
  slug: string;
  parentCode?: string;
  imageUrl?: string;
  description?: string;
  displayOrder?: number;
  isActive?: boolean;
}): Promise<Category> {
  return apiFetch<Category>("/v1/categories", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}
