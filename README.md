# Mẹ & Bé Shop — Monorepo (Backend + Frontend)

Dự án website bán hàng Mẹ & Bé (e-commerce + blog). Repo gồm 2 phần:

| Thư mục | Công nghệ | Vai trò |
|---------|-----------|---------|
| `mevabe/` | Spring Boot 3.3 (Java 21) | Backend REST API |
| `frontend/` | Next.js 15 (React + TypeScript) | Giao diện người dùng |
| `mevabe_shop_v2.sql` | MySQL 8 | Lược đồ CSDL gốc (nguồn để tạo migration Flyway) |
| `mevabe/src/main/resources/db/migration/` | Flyway | Migration CSDL có đánh version (`V1__init_schema.sql`) |
| `docker-compose.yml` | Docker | Hạ tầng: MySQL, Redis, Kafka, các UI |

Kiến trúc backend được thiết kế theo kiểu **Ports & Adapters** để về sau **cắm thêm Redis / Hàng đợi / Kafka mà không phải sửa code nghiệp vụ**.

Cách team làm việc (ticket → nhánh → PR → CI): xem [docs/CACH_LAM_VIEC.md](docs/CACH_LAM_VIEC.md). Biến môi trường mẫu: [`.env.example`](.env.example) (copy thành `.env`, không commit file `.env`).

---

## 0. Luồng chuẩn trước khi code

1. **Tạo issue** trên GitHub (template *Tính năng* hoặc *Bug*) — đây là ticket.
2. **Tạo nhánh** từ `main`, đặt tên theo issue:

```bash
git checkout main
git pull
git checkout -b feat/MEV-12-mo-ta-ngan
```

3. **Mở pull request** vào `main` (điền template, đợi CI xanh, rồi mới merge). Không push thẳng lên `main`.

CI chạy Maven test (backend) và `npm run lint` (frontend) trên mỗi PR.

---

## 1. Yêu cầu máy (bạn đã có sẵn)

- Java 21+ (đang dùng JDK 22) — chạy backend
- Node.js 20+ (đang dùng 22) — chạy frontend
- Docker — chạy MySQL/Redis/Kafka
- Maven đã có sẵn, ngoài ra backend còn kèm `mvnw` (Maven wrapper)

---

## 2. Khởi động NHANH (3 bước)

### Bước 1 — Bật cơ sở dữ liệu (MySQL) bằng Docker

```bash
docker compose up -d mysql adminer
```

- MySQL của Docker khởi động **rỗng**. Việc tạo bảng + dữ liệu mẫu do **Flyway** lo (xem mục *Flyway* bên dưới), chạy tự động khi backend khởi động ở Bước 2.
- MySQL của Docker mở ở cổng **3307** trên máy thật (để tránh đụng MySQL local thường chiếm 3306). Backend đã trỏ sẵn tới 3307.
- Xem/sửa DB trực quan tại **Adminer**: http://localhost:8081
  - Hệ thống: `MySQL` · Server: `mysql` · User: `mevabe` · Pass: `mevabe123` · DB: `mevabe_shop`

> Muốn dựng lại DB **hoàn toàn từ đầu bằng Flyway**: `docker compose down -v` rồi `docker compose up -d mysql` (DB rỗng), sau đó chạy backend — Flyway sẽ chạy `V1__init_schema.sql` để tạo toàn bộ bảng, trigger và dữ liệu mẫu.

### Bước 2 — Chạy Backend

```bash
cd mevabe
./mvnw spring-boot:run        # Windows: .\mvnw.cmd spring-boot:run
```

- API chạy ở: http://localhost:8080/api
- **Swagger UI (thử API ngay trên trình duyệt):** http://localhost:8080/api/swagger-ui.html
- Health check: http://localhost:8080/api/actuator/health

Thử nhanh:
```bash
curl http://localhost:8080/api/v1/categories
```

### Bước 3 — Chạy Frontend

```bash
cd frontend
npm run dev
```

- Web chạy ở: http://localhost:3000
- Trang demo gọi backend: http://localhost:3000/categories

---

## 3. Cấu trúc Backend (`mevabe/`)

```
src/main/java/vn/mevabe/shop/
├── MevabeShopApplication.java      # Điểm khởi động (@EnableAsync, @EnableScheduling)
├── common/                         # Dùng chung toàn hệ thống
│   ├── response/  ApiResponse, PageResponse      # Định dạng trả về chuẩn
│   ├── exception/ AppException, ErrorCode, GlobalExceptionHandler
│   ├── entity/    BaseEntity        # id + created_at/updated_at tự động
│   └── util/      CodeGenerator      # Sinh mã *_code
├── config/                         # Cấu hình
│   ├── SecurityConfig  (hiện permit-all, sẵn sàng cắm JWT)
│   ├── OpenApiConfig   (Swagger)
│   ├── JpaConfig       (auditing)
│   └── AsyncConfig     (hàng đợi nền / thread pool)
├── infrastructure/                 # ⭐ Cổng hạ tầng (Ports & Adapters)
│   ├── cache/     CacheService (port) ─ InMemory / Redis (adapter)
│   └── messaging/ EventPublisher (port) ─ Logging / Kafka (adapter)
└── modules/                        # Các module nghiệp vụ
    └── category/                   # ⭐ MODULE MẪU (copy theo để làm module khác)
        ├── entity/      Category
        ├── repository/  CategoryRepository
        ├── dto/         CategoryRequest, CategoryResponse
        ├── mapper/      CategoryMapper
        ├── service/     CategoryService (+ Impl)
        └── controller/  CategoryController
```

### Vì sao thiết kế này "cắm gì cũng được"?

Code nghiệp vụ (trong `modules/`) **chỉ phụ thuộc interface** (`CacheService`, `EventPublisher`), không biết bên dưới là công nghệ gì. Đổi công nghệ = **đổi 1 dòng cấu hình**, không sửa service:

| Cấu hình | Giá trị | Kết quả |
|----------|---------|---------|
| `app.cache.provider` | `memory` (mặc định) / `redis` | Cache bằng RAM hoặc Redis |
| `app.messaging.provider` | `log` (mặc định) / `kafka` | Ghi log hoặc bắn sự kiện qua Kafka |

---

## 4. Bật Redis / Kafka khi cần

### Redis (cache)

```bash
docker compose --profile cache up -d redis
```
Rồi chạy backend với biến môi trường:
```bash
# Windows PowerShell
$env:APP_CACHE_PROVIDER="redis"; cd mevabe; .\mvnw.cmd spring-boot:run
```
Backend tự chuyển sang `RedisCacheService` — **không cần sửa code**.

### Kafka (message broker)

```bash
docker compose --profile stream up -d kafka kafka-ui
```
- Kafka UI: http://localhost:8082
- Chạy backend với `APP_MESSAGING_PROVIDER=kafka` → sự kiện được bắn sang topic `mevabe.<TênSựKiện>`.

### Bật tất cả cùng lúc

```bash
docker compose --profile cache --profile stream up -d
```

---

## 4.1 Flyway — quản lý & version hoá cơ sở dữ liệu

Backend dùng **Flyway** để tạo/nâng cấp schema tự động, có đánh version. Mỗi lần khởi động, Flyway kiểm tra bảng `flyway_schema_history` và chạy các migration còn thiếu.

- Migration nằm tại: `mevabe/src/main/resources/db/migration/`
- Quy tắc đặt tên: `V<số>__<mô_tả>.sql` (ví dụ `V1__init_schema.sql`, `V2__add_wishlist.sql`).
- **Không sửa file migration đã chạy** — luôn tạo file `V2`, `V3`... mới cho thay đổi tiếp theo.

**Hai tình huống khi chạy:**

| Trạng thái DB | Flyway làm gì |
|---------------|----------------|
| DB **rỗng** (mới `docker compose down -v && up`) | Chạy `V1` tạo toàn bộ bảng + trigger + dữ liệu mẫu |
| DB **đã có sẵn** bảng (chưa có lịch sử Flyway) | `baseline-on-migrate` đánh dấu là đã ở `V1` (không chạy lại), rồi chỉ chạy `V2`+ |

**Lưu ý kỹ thuật (đã cấu hình sẵn):** file SQL gốc dùng `DELIMITER` cho trigger — không tương thích Flyway, nên trong `V1__init_schema.sql` đã bỏ `DELIMITER` (Flyway tự hiểu khối `BEGIN...END`). Ngoài ra MySQL cần cờ `--log-bin-trust-function-creators=1` để user thường tạo được trigger — đã thêm vào `docker-compose.yml`.

Thêm một thay đổi CSDL mới:
```bash
# Tạo file mới, ví dụ:
# mevabe/src/main/resources/db/migration/V2__them_bang_khuyen_mai.sql
# Rồi khởi động lại backend — Flyway tự chạy V2.
```

---

## 5. Cách thêm một module mới (ví dụ: `brand`, `product`...)

Copy y hệt cấu trúc module `category`, đổi tên. 6 lớp cần tạo:

1. **entity** — ánh xạ bảng DB (kế thừa `BaseEntity`).
2. **repository** — kế thừa `JpaRepository`.
3. **dto** — `XxxRequest` (đầu vào, có validation) + `XxxResponse` (đầu ra).
4. **mapper** — chuyển Entity ⇄ DTO.
5. **service** — interface + impl (chứa logic, dùng `CacheService`/`EventPublisher` nếu cần).
6. **controller** — REST endpoint, chỉ gọi service và trả `ApiResponse`.

> Mẹo: mở module `category` để làm khuôn, đây là bản mẫu đã chạy được.

---

## 6. Frontend (`frontend/`)

```
src/
├── app/
│   ├── layout.tsx            # Layout gốc (metadata, font)
│   ├── (shop)/               # Nhóm route khu MUA SẮM (Header + Footer)
│   │   ├── layout.tsx
│   │   ├── page.tsx          # Trang chủ
│   │   ├── categories/       # Danh mục (gọi backend thật)
│   │   └── products/         # Sản phẩm (khung mẫu)
│   └── admin/                # Khu QUẢN TRỊ (sidebar riêng)
│       ├── layout.tsx
│       └── page.tsx          # Dashboard
├── components/
│   ├── layout/               # Header, Footer
│   └── ui/                   # Container, Button, Card, Badge, PageHeader
├── features/                 # Chia theo tính năng
│   ├── categories/api.ts     # Client gọi API Category (mẫu chạy được)
│   └── products/api.ts       # Client mẫu cho Product
└── lib/
    ├── api.ts                # Hàm fetch dùng chung (khớp ApiResponse backend)
    ├── config.ts             # Cấu hình tập trung (URL API, menu, tên site)
    ├── types.ts              # Kiểu dữ liệu chung
    └── cn.ts                 # Tiện ích ghép class
```

Các route: `/` (trang chủ), `/categories` (dữ liệu thật), `/products` (mẫu), `/admin` (quản trị).

Cấu hình URL backend ở `frontend/.env.local`:
```
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080/api
```

---

## 7. Các cổng (port) đang dùng

| Dịch vụ | URL |
|---------|-----|
| Backend API | http://localhost:8080/api |
| Swagger UI | http://localhost:8080/api/swagger-ui.html |
| Frontend | http://localhost:3000 |
| MySQL (Docker) | localhost:3307 |
| Adminer (xem DB) | http://localhost:8081 |
| Redis | localhost:6379 |
| Kafka | localhost:9092 |
| Kafka UI | http://localhost:8082 |

---

## 8. Lộ trình gợi ý (khi credit AI đã hết)

1. Làm module **Auth** (đăng ký/đăng nhập JWT) → siết `SecurityConfig` từ `permitAll` sang `authenticated`.
2. Nhân bản module cho các bảng lớn: `brands`, `products`, `product_variants`, `orders`...
3. Bật Redis để cache danh mục/sản phẩm bán chạy.
4. Bật Kafka cho sự kiện `OrderCreated` → xử lý tồn kho, gửi email bất đồng bộ.
5. Dựng giao diện frontend theo từng `feature`.
```
