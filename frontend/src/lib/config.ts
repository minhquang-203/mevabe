// Cau hinh tap trung cua frontend. Sua o day, dung khap noi.

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080/api";

export const siteConfig = {
  name: "Mẹ & Bé Shop",
  shortName: "Mẹ & Bé",
  description: "Cửa hàng mẹ & bé — sữa, bỉm, đồ sơ sinh, thời trang, đồ chơi.",
  // Menu dieu huong chinh
  nav: [
    { label: "Trang chủ", href: "/" },
    { label: "Danh mục", href: "/categories" },
    { label: "Sản phẩm", href: "/products" },
    { label: "Quản trị", href: "/admin" },
  ],
} as const;
