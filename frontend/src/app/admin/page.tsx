import { Card } from "@/components/ui/Card";
import { PageHeader } from "@/components/ui/PageHeader";

export const metadata = { title: "Quản trị" };

const stats = [
  { label: "Đơn hàng hôm nay", value: "—" },
  { label: "Doanh thu", value: "—" },
  { label: "Sản phẩm", value: "—" },
  { label: "Khách hàng", value: "—" },
];

export default function AdminDashboardPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Tổng quan"
        description="Bảng điều khiển quản trị (khung mẫu — nối số liệu thật sau)"
      />
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((s) => (
          <Card key={s.label}>
            <p className="text-sm text-zinc-500">{s.label}</p>
            <p className="mt-2 text-2xl font-bold text-zinc-900">{s.value}</p>
          </Card>
        ))}
      </div>
      <Card>
        <p className="text-sm text-zinc-600">
          Đây là khung khu vực quản trị. Sau khi làm module Auth (JWT) và phân
          quyền, hãy bảo vệ các trang <code>/admin/*</code> và nối dữ liệu thật
          từ backend.
        </p>
      </Card>
    </div>
  );
}
