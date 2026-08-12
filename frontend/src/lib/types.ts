// Cac kieu du lieu dung chung, khop voi backend (ApiResponse, PageResponse).

export interface ApiResponse<T> {
  success: boolean;
  code: string;
  message: string;
  data: T;
  errors?: unknown;
  timestamp: string;
}

export interface PageResponse<T> {
  items: T[];
  page: number;
  size: number;
  totalItems: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

export interface Category {
  id: number;
  categoryCode: string;
  parentCode: string | null;
  name: string;
  slug: string;
  imageUrl: string | null;
  description: string | null;
  displayOrder: number | null;
  isActive: boolean | null;
  createdAt: string;
  updatedAt: string;
}

// Mau kieu du lieu cho module tiep theo (backend chua lam - de san khi lam toi).
export interface Product {
  id: number;
  productCode: string;
  categoryCode: string;
  brandCode: string | null;
  sku: string;
  name: string;
  slug: string;
  shortDescription: string | null;
  basePrice: number;
  salePrice: number | null;
  isFeatured: boolean;
  isActive: boolean;
  avgRating: number;
  soldCount: number;
}
