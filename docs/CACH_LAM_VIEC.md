# Cách làm việc trên repo Mevabe

File này mô phỏng cách một team sản phẩm làm việc hàng ngày. Mục tiêu: quen **ticket → nhánh → PR → CI → merge**, và cắt việc theo nghiệp vụ shop.

Flow: **GitHub Flow**. Mọi thay đổi đi nhánh ngắn từ `main`, vào `main` bằng pull request. Không dùng GitFlow (`develop` / `release`) ở đây.

```
issue (ticket)  →  nhánh feat/fix  →  pull request  →  CI xanh  →  merge vào main
```

## 1. Không code nếu chưa có issue

Issue = ticket. Trước khi mở editor:

1. Tạo issue (template *Tính năng* hoặc *Bug*).
2. Gắn **nghiệp vụ**: `catalog` / `identity` / `commerce` / `content`.
3. Viết tiêu chí chấp nhận (mục 5).
4. Mới checkout nhánh.

Số issue trên GitHub đóng vai trò mã ticket. Ví dụ issue `#12` → nhánh `feat/MEV-12-...`.

## 2. Đặt tên nhánh

```
<loại>/MEV-<số-issue>-<mô-tả-ngắn>
```

| Loại | Khi nào |
|------|---------|
| `feat` | Tính năng mới |
| `fix` | Sửa lỗi |
| `chore` | CI, docs, vệ sinh repo — không đổi hành vi người dùng |

Ví dụ: `feat/MEV-12-loc-san-pham`, `fix/MEV-15-gia-am`.

Một nhánh = một issue. Xong thì xóa nhánh sau khi merge.

## 3. Pull request

- 1 PR = 1 việc. Đừng gom auth + giỏ hàng vào cùng PR.
- Mô tả **vì sao** đổi, không liệt kê “sửa file X”.
- PR template bắt buộc: liên kết issue (`Closes #12`), cách test, rủi ro.
- CI (GitHub Actions) phải xanh trước khi merge. Không merge khi check đỏ.
- Không commit `.env`, mật khẩu, JWT secret, PDF lạ, hay `.idea/`.

## 4. Tự review như reviewer

Trước khi bấm merge (bạn đóng cả vai reviewer):

- [ ] Đúng phạm vi ticket, không “sửa luôn chỗ bên cạnh”.
- [ ] Tiêu chí chấp nhận trong issue đều được đáp ứng.
- [ ] Không có secret / file rác.
- [ ] API/UI lỗi rõ ràng, không nuốt exception.
- [ ] Migration Flyway (nếu có) là file **mới** (`V2`, `V3`…), không sửa file đã chạy.
- [ ] Đã tự chạy bước “cách test” ghi trong PR.

## 5. Mẫu ticket

**Mục tiêu** — người dùng/admin làm được gì sau khi xong.

**Phạm vi** — làm gì / không làm gì (ví dụ: chỉ API, chưa UI).

**Tiêu chí chấp nhận** — Given / When / Then:

```
Given danh mục "Sữa bột" đang hiện trên trang chủ
When admin tắt isActive
Then API danh mục public không còn trả danh mục đó
```

Càng cụ thể càng dễ tự review.

## 6. Bản đồ nghiệp vụ (để cắt ticket)

Gắn mỗi issue đúng miền. Đừng để một ticket đụng hai miền nếu có thể tách.

| Miền | Trách nhiệm | Trong repo hiện tại |
|------|-------------|---------------------|
| `catalog` | Danh mục, sản phẩm, biến thể, thương hiệu | `modules/category`, `modules/product` |
| `identity` | Đăng ký, đăng nhập, JWT, phân quyền | Chưa có — lần sau |
| `commerce` | Giỏ hàng, đơn, thanh toán, tồn kho | Chưa có — lần sau |
| `content` | Blog, bài viết, banner | Chưa có — lần sau |

Hạ tầng dùng chung (`common/`, `infrastructure/cache`, `infrastructure/messaging`) không phải miền nghiệp vụ. Ticket đụng chỗ này ghi rõ “nền tảng”, vẫn nên nhỏ.

## 7. Môi trường

| Môi trường | Ý nghĩa |
|------------|---------|
| Máy local | Docker Compose (MySQL…) + backend + frontend. Biến mẫu: [`.env.example`](../.env.example). |
| CI | GitHub Actions: `mvn test` + `npm run lint`. Không cần MySQL cho unit test hiện tại. |
| `main` | Nhánh luôn chạy được. Không push thẳng lên `main` khi đã bật bảo vệ nhánh. |

Sau khi cài GitHub CLI (`gh`): bật branch protection trên `main` (bắt buộc PR, bắt buộc check CI xanh).

## 8. Luyện một vòng đầy đủ

1. Mở issue nhỏ (ví dụ: thêm test cho mapper, hoặc sửa copy UI).
2. Tạo nhánh theo mục 2.
3. Code đúng phạm vi.
4. Mở PR, điền template, đợi CI.
5. Tự review checklist mục 4, rồi merge.

Lần sau, mỗi tính năng shop mới đi đúng luồng này — đó mới là phần “nghiệp vụ team”.
