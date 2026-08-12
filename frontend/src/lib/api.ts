import type { ApiResponse } from "./types";
import { API_BASE_URL as BASE_URL } from "./config";

/**
 * Loi API co cau truc, giu lai code/message tu backend de UI hien thi.
 */
export class ApiError extends Error {
  code: string;
  status: number;
  errors?: unknown;

  constructor(status: number, code: string, message: string, errors?: unknown) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = code;
    this.errors = errors;
  }
}

/**
 * Ham goi API dung chung. Tu dong:
 *  - Ghep BASE_URL
 *  - Gan header JSON
 *  - Boc/thao lop ApiResponse cua backend
 *  - Nem ApiError khi that bai
 *
 * Sau nay them Authorization (JWT) chi can sua o 1 cho nay.
 */
export async function apiFetch<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(options.headers ?? {}),
    },
    cache: "no-store",
  });

  let body: ApiResponse<T> | null = null;
  try {
    body = (await res.json()) as ApiResponse<T>;
  } catch {
    // Response khong phai JSON
  }

  if (!res.ok || !body?.success) {
    throw new ApiError(
      res.status,
      body?.code ?? "UNKNOWN",
      body?.message ?? `Loi ${res.status}`,
      body?.errors
    );
  }

  return body.data;
}
