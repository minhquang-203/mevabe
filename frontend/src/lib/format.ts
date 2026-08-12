// Dinh dang tien te VND: 250000 -> "250.000 ₫"
export function formatVND(value: number | null | undefined): string {
  if (value == null) return "—";
  return new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    maximumFractionDigits: 0,
  }).format(value);
}
