# MeVaBe Admin Frontend

Khung giao diện quản trị (Vue 3 + Vite + Bootstrap 5) cho website mẹ và bé.

## Chạy dự án

```sh
npm install
npm run dev
```

Mặc định dùng **mock API** (`VITE_USE_MOCK=true` trong `.env.development`).

- Đăng nhập: email/mật khẩu bất kỳ (đã điền sẵn trên form)
- Sau login: Dashboard → menu **Sản phẩm** để xem CRUD mẫu

Khi backend sẵn sàng, đặt:

```env
VITE_USE_MOCK=false
VITE_API_BASE_URL=http://localhost:8080/api
```

## Cấu trúc chính

```text
src/
  api/
    http.js              # axios + interceptor + bóc ApiResponse
    mock/                # dữ liệu giả khi VITE_USE_MOCK=true
    modules/             # mỗi feature 1 file API
  components/            # PageHeader, TableToolbar, Pagination, StatusTag
  config/menu.js         # menu sidebar
  constants/             # enum, phân trang, storage keys
  layouts/               # AdminLayout, BlankLayout
  router/                # routes + auth guard
  stores/                # auth, app (sidebar)
  utils/format.js
  utils/notify.js        # toast + confirm (Bootstrap)
  views/
    auth/
    dashboard/
    products/            # module CRUD mẫu
```

## Quy ước thêm chức năng mới

Khi thêm feature (ví dụ: `orders`), làm theo 4 bước:

1. **API module** — tạo `src/api/modules/orders.js` theo mẫu `products.js`
2. **Views** — tạo `src/views/orders/` (`OrderListView.vue`, `OrderFormView.vue` nếu cần)
3. **Route** — thêm route con trong `src/router/index.js` dưới `AdminLayout`, đặt `meta.title` + `meta.requiresAuth`
4. **Menu** — thêm mục vào `src/config/menu.js` (bỏ `disabled: true` nếu đang placeholder)

Nếu cần mock tạm thời: bổ sung handler trong `src/api/mock/index.js`.

## Scripts

```sh
npm run dev      # chạy local
npm run build    # build production
npm run preview  # xem bản build
```
