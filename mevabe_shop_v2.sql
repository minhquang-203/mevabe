-- ================================================================
-- CƠ SỞ DỮ LIỆU: WEBSITE BÁN HÀNG MẸ & BÉ (E-COMMERCE + BLOG)
-- PHIÊN BẢN 2.3 — Chuẩn hóa kiểu chuỗi:
--   + *_code và mã kỹ thuật: VARCHAR
--   + Thông tin tiếng Việt: NVARCHAR (cột ngắn); TEXT/LONGTEXT (nội dung dài)
-- PHIÊN BẢN 2.2 — Chuẩn hóa khóa:
--   + id BIGINT AUTO_INCREMENT PRIMARY KEY trên mọi bảng
--   + Mã nghiệp vụ *_code VARCHAR UNIQUE; nội dung hiển thị dùng NVARCHAR
--   + FK tham chiếu theo *_code; bổ sung UNIQUE toàn vẹn dữ liệu
--   kế thừa 2.1: cấu hình hệ thống, phân quyền, newsletter, chuyển kho,
--   tách giảm giá đơn hàng, hoàn tiền; kế thừa 2.0 guest checkout...
-- DBMS: MySQL 8.0+ / MariaDB 10.6+
-- Charset: utf8mb4 (hỗ trợ đầy đủ tiếng Việt và emoji)
-- ================================================================

CREATE DATABASE IF NOT EXISTS mevabe_shop
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE mevabe_shop;

-- ================================================================
-- KHỐI 1: NGƯỜI DÙNG
-- ================================================================

CREATE TABLE roles (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_code   VARCHAR(50) NOT NULL COMMENT 'admin, staff, customer',
    role_name   VARCHAR(50) NOT NULL,
    description NVARCHAR(255),
    UNIQUE KEY uq_roles_code (role_code),
    UNIQUE KEY uq_roles_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE permissions (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    permission_code  VARCHAR(100) NOT NULL COMMENT 'VD: products.manage, orders.manage',
    module_name      NVARCHAR(100) NOT NULL,
    description      NVARCHAR(255),
    UNIQUE KEY uq_permissions_code (permission_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE role_permissions (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_code        VARCHAR(50) NOT NULL,
    permission_code  VARCHAR(100) NOT NULL,
    UNIQUE KEY uq_role_permission (role_code, permission_code),
    FOREIGN KEY (role_code) REFERENCES roles(role_code) ON DELETE CASCADE,
    FOREIGN KEY (permission_code) REFERENCES permissions(permission_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
    id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_code          VARCHAR(50) NOT NULL,
    role_code          VARCHAR(50) NOT NULL DEFAULT 'customer',
    tier_code          VARCHAR(50) DEFAULT NULL COMMENT 'Hạng thành viên, FK thêm ở KHỐI 9',
    full_name          NVARCHAR(100) NOT NULL,
    email              VARCHAR(150) NOT NULL,
    phone              VARCHAR(15),
    password_hash      VARCHAR(255) NOT NULL,
    avatar_url         VARCHAR(500),
    gender             ENUM('male','female','other'),
    birth_date         DATE,
    loyalty_points     INT UNSIGNED NOT NULL DEFAULT 0,
    is_active          BOOLEAN DEFAULT TRUE,
    email_verified_at  DATETIME,
    last_login_at      DATETIME,
    created_at         DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_users_code (user_code),
    UNIQUE KEY uq_users_email (email),
    UNIQUE KEY uq_users_phone (phone),
    FOREIGN KEY (role_code) REFERENCES roles(role_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE addresses (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    address_code    VARCHAR(50) NOT NULL,
    user_code       VARCHAR(50) NOT NULL,
    recipient_name  NVARCHAR(100) NOT NULL,
    phone           VARCHAR(15) NOT NULL,
    province        NVARCHAR(100) NOT NULL,
    district        NVARCHAR(100) NOT NULL,
    ward            NVARCHAR(100) NOT NULL,
    detail_address  NVARCHAR(255) NOT NULL,
    address_type    ENUM('home','office','other') DEFAULT 'home',
    is_default      BOOLEAN DEFAULT FALSE,
    -- Cột ảo: chỉ có giá trị khi is_default=TRUE, ép mỗi user tối đa 1 địa chỉ mặc định
    default_owner   VARCHAR(50) AS (IF(is_default = TRUE, user_code, NULL)) VIRTUAL,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_addresses_code (address_code),
    UNIQUE KEY uq_one_default_per_user (default_owner),
    FOREIGN KEY (user_code) REFERENCES users(user_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- CÁCH DÙNG (tầng ứng dụng): khi đặt 1 địa chỉ làm mặc định, luôn chạy trong 1 transaction:
--   1) UPDATE addresses SET is_default = FALSE WHERE user_code = ? AND is_default = TRUE;
--   2) UPDATE addresses SET is_default = TRUE  WHERE address_code = ?;

CREATE TABLE user_tokens (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    token_code  VARCHAR(50) NOT NULL,
    user_code   VARCHAR(50) NOT NULL,
    token       VARCHAR(255) NOT NULL,
    type        ENUM('email_verify','password_reset') NOT NULL,
    expires_at  DATETIME NOT NULL,
    used_at     DATETIME DEFAULT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_tokens_code (token_code),
    UNIQUE KEY uq_user_tokens_token (token),
    FOREIGN KEY (user_code) REFERENCES users(user_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 2: DANH MỤC & SẢN PHẨM
-- ================================================================

CREATE TABLE categories (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_code  VARCHAR(50) NOT NULL,
    parent_code    VARCHAR(50) DEFAULT NULL,
    name           NVARCHAR(100) NOT NULL,
    slug           VARCHAR(120) NOT NULL,
    image_url      VARCHAR(500),
    description    TEXT,
    display_order  INT DEFAULT 0,
    is_active      BOOLEAN DEFAULT TRUE,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_categories_code (category_code),
    UNIQUE KEY uq_categories_slug (slug),
    FOREIGN KEY (parent_code) REFERENCES categories(category_code) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE brands (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    brand_code      VARCHAR(50) NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    slug            VARCHAR(120) NOT NULL,
    logo_url        VARCHAR(500),
    country_origin  NVARCHAR(100),
    description     TEXT,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_brands_code (brand_code),
    UNIQUE KEY uq_brands_name (name),
    UNIQUE KEY uq_brands_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE age_groups (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    age_group_code  VARCHAR(50) NOT NULL,
    name            NVARCHAR(50) NOT NULL COMMENT 'VD: 0-6 tháng, 1-3 tuổi, Mẹ bầu',
    min_month       INT,
    max_month       INT,
    display_order   INT DEFAULT 0,
    UNIQUE KEY uq_age_groups_code (age_group_code),
    UNIQUE KEY uq_age_groups_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_code        VARCHAR(50) NOT NULL,
    category_code       VARCHAR(50) NOT NULL,
    brand_code          VARCHAR(50),
    sku                 VARCHAR(50) NOT NULL,
    name                NVARCHAR(255) NOT NULL,
    slug                VARCHAR(280) NOT NULL,
    short_description   NVARCHAR(500),
    description         TEXT,
    origin_country      NVARCHAR(100) COMMENT 'Xuất xứ',
    gender_target       ENUM('boy','girl','unisex') DEFAULT 'unisex',
    base_price          DECIMAL(12,0) NOT NULL,
    sale_price          DECIMAL(12,0),
    sale_price_start    DATETIME DEFAULT NULL COMMENT 'Thời điểm bắt đầu áp dụng giá sale',
    sale_price_end      DATETIME DEFAULT NULL COMMENT 'Thời điểm hết hạn giá sale',
    cost_price          DECIMAL(12,0),
    weight_gram         INT UNSIGNED,
    is_featured         BOOLEAN DEFAULT FALSE,
    is_active           BOOLEAN DEFAULT TRUE,
    view_count          INT UNSIGNED DEFAULT 0,
    sold_count          INT UNSIGNED DEFAULT 0,
    avg_rating          DECIMAL(2,1) DEFAULT 0,
    meta_title          NVARCHAR(255),
    meta_description    NVARCHAR(500),
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_products_code (product_code),
    UNIQUE KEY uq_products_sku (sku),
    UNIQUE KEY uq_products_slug (slug),
    FOREIGN KEY (category_code) REFERENCES categories(category_code),
    FOREIGN KEY (brand_code) REFERENCES brands(brand_code) ON DELETE SET NULL,
    CHECK (base_price >= 0),
    CHECK (sale_price_end IS NULL OR sale_price_start IS NULL OR sale_price_end >= sale_price_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_age_groups (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_code    VARCHAR(50) NOT NULL,
    age_group_code  VARCHAR(50) NOT NULL,
    UNIQUE KEY uq_product_age_group (product_code, age_group_code),
    FOREIGN KEY (product_code) REFERENCES products(product_code) ON DELETE CASCADE,
    FOREIGN KEY (age_group_code) REFERENCES age_groups(age_group_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_attributes (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    attribute_code   VARCHAR(50) NOT NULL,
    product_code     VARCHAR(50) NOT NULL,
    attribute_name   NVARCHAR(100) NOT NULL COMMENT 'VD: Chất liệu, Thành phần, Chứng nhận an toàn',
    attribute_value  NVARCHAR(500) NOT NULL,
    UNIQUE KEY uq_product_attributes_code (attribute_code),
    UNIQUE KEY uq_product_attribute_name (product_code, attribute_name),
    FOREIGN KEY (product_code) REFERENCES products(product_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_variants (
    id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    variant_code       VARCHAR(50) NOT NULL,
    product_code       VARCHAR(50) NOT NULL,
    sku                VARCHAR(50) NOT NULL,
    barcode            VARCHAR(50) COMMENT 'Mã vạch, dùng khi bán tại cửa hàng/quét kho',
    variant_name       NVARCHAR(150) NOT NULL COMMENT 'VD: Size M - Xanh dương',
    size               NVARCHAR(50),
    color              NVARCHAR(50),
    price_adjustment   DECIMAL(12,0) DEFAULT 0 COMMENT 'Chênh lệch so với base_price, có thể âm',
    is_active          BOOLEAN DEFAULT TRUE,
    created_at         DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_product_variants_code (variant_code),
    UNIQUE KEY uq_product_variants_sku (sku),
    UNIQUE KEY uq_product_variants_barcode (barcode),
    FOREIGN KEY (product_code) REFERENCES products(product_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_images (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    image_code     VARCHAR(50) NOT NULL,
    product_code   VARCHAR(50) NOT NULL,
    variant_code   VARCHAR(50) DEFAULT NULL,
    image_url      VARCHAR(500) NOT NULL,
    is_primary     BOOLEAN DEFAULT FALSE,
    display_order  INT DEFAULT 0,
    UNIQUE KEY uq_product_images_code (image_code),
    FOREIGN KEY (product_code) REFERENCES products(product_code) ON DELETE CASCADE,
    FOREIGN KEY (variant_code) REFERENCES product_variants(variant_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 3: KHO HÀNG
-- ================================================================

CREATE TABLE warehouses (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    warehouse_code  VARCHAR(50) NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    address         NVARCHAR(255),
    phone           VARCHAR(15),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_warehouses_code (warehouse_code),
    UNIQUE KEY uq_warehouses_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inventory (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    inventory_code       VARCHAR(50) NOT NULL,
    variant_code         VARCHAR(50) NOT NULL,
    warehouse_code       VARCHAR(50) NOT NULL,
    quantity             INT UNSIGNED NOT NULL DEFAULT 0,
    reserved_quantity    INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Đã giữ cho đơn hàng chưa xử lý xong',
    low_stock_threshold  INT UNSIGNED NOT NULL DEFAULT 5 COMMENT 'Dưới ngưỡng này sẽ cảnh báo cần nhập thêm',
    updated_at           DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_code (inventory_code),
    UNIQUE KEY uq_variant_warehouse (variant_code, warehouse_code),
    FOREIGN KEY (variant_code) REFERENCES product_variants(variant_code) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_code) REFERENCES warehouses(warehouse_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE stock_movements (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    movement_code    VARCHAR(50) NOT NULL,
    variant_code     VARCHAR(50) NOT NULL,
    warehouse_code   VARCHAR(50) NOT NULL,
    movement_type    ENUM('in','out','adjustment') NOT NULL,
    quantity         INT NOT NULL,
    reference_type   ENUM('order','purchase','manual','return','transfer') NOT NULL,
    reference_code   VARCHAR(50) COMMENT 'Mã nghiệp vụ tham chiếu (order_code, transfer_code...)',
    note             NVARCHAR(255),
    created_by_code  VARCHAR(50) COMMENT 'user_code nhân viên thực hiện',
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_stock_movements_code (movement_code),
    FOREIGN KEY (variant_code) REFERENCES product_variants(variant_code),
    FOREIGN KEY (warehouse_code) REFERENCES warehouses(warehouse_code),
    FOREIGN KEY (created_by_code) REFERENCES users(user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE stock_transfers (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    transfer_code         VARCHAR(50) NOT NULL,
    from_warehouse_code   VARCHAR(50) NOT NULL,
    to_warehouse_code     VARCHAR(50) NOT NULL,
    status                ENUM('pending','completed','cancelled') NOT NULL DEFAULT 'pending',
    note                  NVARCHAR(255),
    created_by_code       VARCHAR(50),
    completed_at          DATETIME DEFAULT NULL,
    created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_stock_transfers_code (transfer_code),
    FOREIGN KEY (from_warehouse_code) REFERENCES warehouses(warehouse_code),
    FOREIGN KEY (to_warehouse_code) REFERENCES warehouses(warehouse_code),
    FOREIGN KEY (created_by_code) REFERENCES users(user_code),
    CHECK (from_warehouse_code <> to_warehouse_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE stock_transfer_items (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    transfer_item_code    VARCHAR(50) NOT NULL,
    transfer_code         VARCHAR(50) NOT NULL,
    variant_code          VARCHAR(50) NOT NULL,
    quantity              INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_stock_transfer_items_code (transfer_item_code),
    UNIQUE KEY uq_transfer_variant (transfer_code, variant_code),
    FOREIGN KEY (transfer_code) REFERENCES stock_transfers(transfer_code) ON DELETE CASCADE,
    FOREIGN KEY (variant_code) REFERENCES product_variants(variant_code),
    CHECK (quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 4: GIỎ HÀNG
-- ================================================================

CREATE TABLE carts (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_code    VARCHAR(50) NOT NULL,
    user_code    VARCHAR(50) DEFAULT NULL,
    session_id   VARCHAR(100) DEFAULT NULL COMMENT 'Cho khách chưa đăng nhập',
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_carts_code (cart_code),
    UNIQUE KEY uq_carts_user (user_code),
    UNIQUE KEY uq_carts_session (session_id),
    FOREIGN KEY (user_code) REFERENCES users(user_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cart_items (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_item_code  VARCHAR(50) NOT NULL,
    cart_code       VARCHAR(50) NOT NULL,
    variant_code    VARCHAR(50) NOT NULL,
    quantity        INT UNSIGNED NOT NULL DEFAULT 1,
    added_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_cart_items_code (cart_item_code),
    UNIQUE KEY uq_cart_variant (cart_code, variant_code),
    FOREIGN KEY (cart_code) REFERENCES carts(cart_code) ON DELETE CASCADE,
    FOREIGN KEY (variant_code) REFERENCES product_variants(variant_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 5: KHUYẾN MÃI
-- ================================================================

CREATE TABLE vouchers (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    voucher_code          VARCHAR(50) NOT NULL COMMENT 'Mã giảm giá khách nhập',
    description           NVARCHAR(255),
    discount_type         ENUM('percentage','fixed') NOT NULL,
    discount_value        DECIMAL(12,0) NOT NULL,
    min_order_value       DECIMAL(12,0) DEFAULT 0,
    max_discount_amount   DECIMAL(12,0),
    usage_limit           INT UNSIGNED COMMENT 'Giới hạn tổng số lượt dùng toàn hệ thống, NULL = không giới hạn',
    usage_limit_per_user  INT UNSIGNED DEFAULT 1 COMMENT 'Giới hạn số lượt dùng của mỗi khách, NULL = không giới hạn',
    used_count            INT UNSIGNED DEFAULT 0,
    start_date            DATETIME NOT NULL,
    end_date              DATETIME NOT NULL,
    is_active             BOOLEAN DEFAULT TRUE,
    created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_vouchers_code (voucher_code),
    CHECK (end_date >= start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE flash_sales (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    flash_sale_code  VARCHAR(50) NOT NULL,
    name             NVARCHAR(150) NOT NULL,
    start_time       DATETIME NOT NULL,
    end_time         DATETIME NOT NULL,
    is_active        BOOLEAN DEFAULT TRUE,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_flash_sales_code (flash_sale_code),
    CHECK (end_time >= start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE flash_sale_items (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    flash_sale_item_code  VARCHAR(50) NOT NULL,
    flash_sale_code       VARCHAR(50) NOT NULL,
    variant_code          VARCHAR(50) NOT NULL,
    sale_price            DECIMAL(12,0) NOT NULL,
    quantity_limit        INT UNSIGNED,
    sold_count            INT UNSIGNED DEFAULT 0,
    UNIQUE KEY uq_flash_sale_items_code (flash_sale_item_code),
    UNIQUE KEY uq_flash_sale_variant (flash_sale_code, variant_code),
    FOREIGN KEY (flash_sale_code) REFERENCES flash_sales(flash_sale_code) ON DELETE CASCADE,
    FOREIGN KEY (variant_code) REFERENCES product_variants(variant_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 6: ĐƠN HÀNG
-- ================================================================

CREATE TABLE shipping_methods (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    shipping_method_code  VARCHAR(50) NOT NULL COMMENT 'VD: standard, express, same_day',
    name                  NVARCHAR(100) NOT NULL,
    base_fee              DECIMAL(12,0) NOT NULL DEFAULT 0,
    estimated_days        NVARCHAR(50),
    display_order         INT DEFAULT 0,
    is_active             BOOLEAN DEFAULT TRUE,
    created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_shipping_methods_code (shipping_method_code),
    UNIQUE KEY uq_shipping_methods_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payment_methods (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_method_code  VARCHAR(50) NOT NULL COMMENT 'VD: cod, bank_transfer, momo, zalopay, vnpay',
    name                 NVARCHAR(100) NOT NULL,
    method_type          ENUM('cod','bank_transfer','ewallet','gateway') NOT NULL DEFAULT 'cod',
    display_order        INT DEFAULT 0,
    is_active            BOOLEAN DEFAULT TRUE,
    created_at           DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_payment_methods_code (payment_method_code),
    UNIQUE KEY uq_payment_methods_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_code           VARCHAR(50) NOT NULL,
    user_code            VARCHAR(50) DEFAULT NULL COMMENT 'NULL nếu là khách vãng lai (guest checkout)',
    guest_email          VARCHAR(150) DEFAULT NULL COMMENT 'Bắt buộc nếu user_code NULL',
    voucher_code         VARCHAR(50) DEFAULT NULL,
    shipping_method_code VARCHAR(50),
    payment_method_code  VARCHAR(50),
    recipient_name       NVARCHAR(100) NOT NULL,
    recipient_phone      VARCHAR(15) NOT NULL,
    shipping_address     NVARCHAR(500) NOT NULL COMMENT 'Snapshot địa chỉ tại thời điểm đặt',
    shipping_partner     VARCHAR(50) DEFAULT NULL COMMENT 'VD: GHN, GHTK, Viettel Post, J&T',
    tracking_code        VARCHAR(50) DEFAULT NULL COMMENT 'Mã vận đơn từ đối tác giao hàng',
    order_status         ENUM('pending','confirmed','processing','shipping','delivered','cancelled','returned') DEFAULT 'pending',
    payment_status       ENUM('unpaid','paid','refunded') DEFAULT 'unpaid',
    subtotal             DECIMAL(12,0) NOT NULL,
    shipping_fee         DECIMAL(12,0) DEFAULT 0,
    voucher_discount     DECIMAL(12,0) NOT NULL DEFAULT 0 COMMENT 'Giảm từ voucher',
    membership_discount  DECIMAL(12,0) NOT NULL DEFAULT 0 COMMENT 'Giảm từ hạng thành viên',
    points_discount      DECIMAL(12,0) NOT NULL DEFAULT 0 COMMENT 'Giảm từ quy đổi điểm',
    points_used          INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Số điểm đã dùng cho đơn',
    discount_amount      DECIMAL(12,0) DEFAULT 0 COMMENT 'Tổng giảm = voucher + membership + points',
    total_amount         DECIMAL(12,0) NOT NULL,
    customer_note        NVARCHAR(500),
    created_at           DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_orders_code (order_code),
    FOREIGN KEY (user_code) REFERENCES users(user_code),
    FOREIGN KEY (voucher_code) REFERENCES vouchers(voucher_code) ON DELETE SET NULL,
    FOREIGN KEY (shipping_method_code) REFERENCES shipping_methods(shipping_method_code),
    FOREIGN KEY (payment_method_code) REFERENCES payment_methods(payment_method_code),
    CHECK (total_amount >= 0),
    CHECK (user_code IS NOT NULL OR guest_email IS NOT NULL),
    CHECK (discount_amount = voucher_discount + membership_discount + points_discount)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_item_code  VARCHAR(50) NOT NULL,
    order_code       VARCHAR(50) NOT NULL,
    variant_code     VARCHAR(50) NOT NULL,
    product_name     NVARCHAR(255) NOT NULL COMMENT 'Snapshot tên sản phẩm',
    variant_name     NVARCHAR(150),
    unit_price       DECIMAL(12,0) NOT NULL COMMENT 'Snapshot giá tại thời điểm mua',
    quantity         INT UNSIGNED NOT NULL,
    subtotal         DECIMAL(12,0) NOT NULL,
    UNIQUE KEY uq_order_items_code (order_item_code),
    FOREIGN KEY (order_code) REFERENCES orders(order_code) ON DELETE CASCADE,
    FOREIGN KEY (variant_code) REFERENCES product_variants(variant_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_status_history (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    history_code     VARCHAR(50) NOT NULL,
    order_code       VARCHAR(50) NOT NULL,
    status           VARCHAR(50) NOT NULL,
    note             NVARCHAR(255),
    changed_by_code  VARCHAR(50) COMMENT 'user_code nhân viên xử lý, NULL nếu hệ thống tự động',
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_order_status_history_code (history_code),
    FOREIGN KEY (order_code) REFERENCES orders(order_code) ON DELETE CASCADE,
    FOREIGN KEY (changed_by_code) REFERENCES users(user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payment_transactions (
    id                        BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_code          VARCHAR(50) NOT NULL,
    order_code                VARCHAR(50) NOT NULL,
    amount                    DECIMAL(12,0) NOT NULL,
    payment_method_code       VARCHAR(50),
    transaction_type          ENUM('payment','refund') NOT NULL DEFAULT 'payment',
    gateway_transaction_code  VARCHAR(100),
    status                    ENUM('pending','success','failed') DEFAULT 'pending',
    gateway_response          TEXT,
    note                      NVARCHAR(255),
    created_by_code           VARCHAR(50) COMMENT 'user_code nhân viên khi hoàn tiền thủ công',
    created_at                DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_payment_transactions_code (transaction_code),
    UNIQUE KEY uq_gateway_transaction_code (gateway_transaction_code),
    FOREIGN KEY (order_code) REFERENCES orders(order_code) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_code) REFERENCES payment_methods(payment_method_code),
    FOREIGN KEY (created_by_code) REFERENCES users(user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE voucher_usages (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    voucher_code  VARCHAR(50) NOT NULL,
    user_code     VARCHAR(50) NOT NULL,
    order_code    VARCHAR(50) NOT NULL,
    used_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_voucher_order (voucher_code, order_code),
    FOREIGN KEY (voucher_code) REFERENCES vouchers(voucher_code),
    FOREIGN KEY (user_code) REFERENCES users(user_code),
    FOREIGN KEY (order_code) REFERENCES orders(order_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE return_requests (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    return_code      VARCHAR(50) NOT NULL,
    order_code       VARCHAR(50) NOT NULL,
    order_item_code  VARCHAR(50) NOT NULL,
    user_code        VARCHAR(50) NOT NULL,
    return_type      ENUM('return','exchange') DEFAULT 'return' COMMENT 'return = trả hàng hoàn tiền, exchange = đổi hàng',
    reason           NVARCHAR(500) NOT NULL,
    status           ENUM('requested','approved','rejected','received','refunded') DEFAULT 'requested',
    refund_amount    DECIMAL(12,0),
    admin_note       NVARCHAR(500),
    approved_by_code VARCHAR(50) COMMENT 'user_code nhân viên duyệt',
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_return_requests_code (return_code),
    UNIQUE KEY uq_return_order_item (order_item_code),
    FOREIGN KEY (order_code) REFERENCES orders(order_code) ON DELETE CASCADE,
    FOREIGN KEY (order_item_code) REFERENCES order_items(order_item_code),
    FOREIGN KEY (user_code) REFERENCES users(user_code),
    FOREIGN KEY (approved_by_code) REFERENCES users(user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE return_images (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    return_image_code VARCHAR(50) NOT NULL,
    return_code       VARCHAR(50) NOT NULL,
    image_url         VARCHAR(500) NOT NULL COMMENT 'Ảnh khách chụp sản phẩm lỗi/không đúng mô tả',
    UNIQUE KEY uq_return_images_code (return_image_code),
    FOREIGN KEY (return_code) REFERENCES return_requests(return_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 7: ĐÁNH GIÁ & YÊU THÍCH
-- ================================================================

CREATE TABLE reviews (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    review_code      VARCHAR(50) NOT NULL,
    product_code     VARCHAR(50) NOT NULL,
    user_code        VARCHAR(50) NOT NULL,
    order_item_code  VARCHAR(50) COMMENT 'Xác thực đã mua hàng',
    rating           TINYINT UNSIGNED NOT NULL,
    comment          TEXT,
    admin_reply      TEXT,
    is_approved      BOOLEAN DEFAULT FALSE,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_reviews_code (review_code),
    UNIQUE KEY uq_reviews_order_item (order_item_code),
    FOREIGN KEY (product_code) REFERENCES products(product_code) ON DELETE CASCADE,
    FOREIGN KEY (user_code) REFERENCES users(user_code) ON DELETE CASCADE,
    FOREIGN KEY (order_item_code) REFERENCES order_items(order_item_code),
    CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE review_images (
    id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    review_image_code  VARCHAR(50) NOT NULL,
    review_code        VARCHAR(50) NOT NULL,
    image_url          VARCHAR(500) NOT NULL,
    UNIQUE KEY uq_review_images_code (review_image_code),
    FOREIGN KEY (review_code) REFERENCES reviews(review_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE wishlists (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_code     VARCHAR(50) NOT NULL,
    product_code  VARCHAR(50) NOT NULL,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_wishlist_user_product (user_code, product_code),
    FOREIGN KEY (user_code) REFERENCES users(user_code) ON DELETE CASCADE,
    FOREIGN KEY (product_code) REFERENCES products(product_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 8: BLOG
-- ================================================================

CREATE TABLE blog_categories (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    blog_category_code  VARCHAR(50) NOT NULL,
    name                NVARCHAR(100) NOT NULL,
    slug                VARCHAR(120) NOT NULL,
    description         NVARCHAR(255),
    display_order       INT DEFAULT 0,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_blog_categories_code (blog_category_code),
    UNIQUE KEY uq_blog_categories_slug (slug),
    UNIQUE KEY uq_blog_categories_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE blog_posts (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    post_code           VARCHAR(50) NOT NULL,
    blog_category_code  VARCHAR(50) NOT NULL,
    author_code         VARCHAR(50) NOT NULL,
    title               NVARCHAR(255) NOT NULL,
    slug                VARCHAR(280) NOT NULL,
    excerpt             NVARCHAR(500),
    content             LONGTEXT NOT NULL,
    featured_image      VARCHAR(500),
    status              ENUM('draft','published','archived') DEFAULT 'draft',
    view_count          INT UNSIGNED DEFAULT 0,
    meta_title          NVARCHAR(255),
    meta_description    NVARCHAR(500),
    published_at        DATETIME,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_blog_posts_code (post_code),
    UNIQUE KEY uq_blog_posts_slug (slug),
    FOREIGN KEY (blog_category_code) REFERENCES blog_categories(blog_category_code),
    FOREIGN KEY (author_code) REFERENCES users(user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE blog_tags (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    tag_code  VARCHAR(50) NOT NULL,
    name      NVARCHAR(50) NOT NULL,
    slug      VARCHAR(60) NOT NULL,
    UNIQUE KEY uq_blog_tags_code (tag_code),
    UNIQUE KEY uq_blog_tags_name (name),
    UNIQUE KEY uq_blog_tags_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE blog_post_tags (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    post_code  VARCHAR(50) NOT NULL,
    tag_code   VARCHAR(50) NOT NULL,
    UNIQUE KEY uq_blog_post_tag (post_code, tag_code),
    FOREIGN KEY (post_code) REFERENCES blog_posts(post_code) ON DELETE CASCADE,
    FOREIGN KEY (tag_code) REFERENCES blog_tags(tag_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE blog_post_products (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    post_code     VARCHAR(50) NOT NULL,
    product_code  VARCHAR(50) NOT NULL,
    UNIQUE KEY uq_blog_post_product (post_code, product_code),
    FOREIGN KEY (post_code) REFERENCES blog_posts(post_code) ON DELETE CASCADE,
    FOREIGN KEY (product_code) REFERENCES products(product_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE blog_comments (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    comment_code         VARCHAR(50) NOT NULL,
    post_code            VARCHAR(50) NOT NULL,
    user_code            VARCHAR(50) DEFAULT NULL,
    parent_comment_code  VARCHAR(50) DEFAULT NULL,
    guest_name           NVARCHAR(100),
    guest_email          VARCHAR(150),
    content              TEXT NOT NULL,
    is_approved          BOOLEAN DEFAULT FALSE,
    created_at           DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_blog_comments_code (comment_code),
    FOREIGN KEY (post_code) REFERENCES blog_posts(post_code) ON DELETE CASCADE,
    FOREIGN KEY (user_code) REFERENCES users(user_code) ON DELETE SET NULL,
    FOREIGN KEY (parent_comment_code) REFERENCES blog_comments(comment_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 9: THÀNH VIÊN THÂN THIẾT (LOYALTY / MEMBERSHIP)
-- ================================================================

CREATE TABLE membership_tiers (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    tier_code         VARCHAR(50) NOT NULL,
    name              NVARCHAR(50) NOT NULL COMMENT 'VD: Thành viên, Bạc, Vàng, Kim cương',
    min_points        INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Điểm tích lũy tối thiểu để đạt hạng này',
    discount_percent  DECIMAL(4,2) DEFAULT 0 COMMENT 'Ưu đãi % tự động cho hạng này',
    benefits          NVARCHAR(500),
    display_order     INT DEFAULT 0,
    UNIQUE KEY uq_membership_tiers_code (tier_code),
    UNIQUE KEY uq_membership_tiers_name (name),
    UNIQUE KEY uq_membership_tiers_min_points (min_points)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE users
    ADD CONSTRAINT fk_users_tier FOREIGN KEY (tier_code) REFERENCES membership_tiers(tier_code) ON DELETE SET NULL;

CREATE TABLE point_transactions (
    id                      BIGINT AUTO_INCREMENT PRIMARY KEY,
    point_transaction_code  VARCHAR(50) NOT NULL,
    user_code               VARCHAR(50) NOT NULL,
    order_code              VARCHAR(50) DEFAULT NULL,
    points                  INT NOT NULL COMMENT 'Dương = cộng điểm, âm = trừ điểm',
    transaction_type        ENUM('earn','redeem','expire','adjustment') NOT NULL,
    note                    NVARCHAR(255),
    created_at              DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_point_transactions_code (point_transaction_code),
    FOREIGN KEY (user_code) REFERENCES users(user_code) ON DELETE CASCADE,
    FOREIGN KEY (order_code) REFERENCES orders(order_code) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 10: NỘI DUNG QUẢN TRỊ (CMS)
-- ================================================================

CREATE TABLE banners (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    banner_code    VARCHAR(50) NOT NULL,
    title          NVARCHAR(150),
    image_url      VARCHAR(500) NOT NULL,
    link_url       VARCHAR(500),
    position       ENUM('homepage_slider','homepage_side','category_top','popup') DEFAULT 'homepage_slider',
    display_order  INT DEFAULT 0,
    start_date     DATETIME,
    end_date       DATETIME,
    is_active      BOOLEAN DEFAULT TRUE,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_banners_code (banner_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pages (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    page_code         VARCHAR(50) NOT NULL,
    title             NVARCHAR(255) NOT NULL,
    slug              VARCHAR(280) NOT NULL COMMENT 'VD: gioi-thieu, chinh-sach-doi-tra, dieu-khoan',
    content           LONGTEXT,
    meta_title        NVARCHAR(255),
    meta_description  NVARCHAR(500),
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pages_code (page_code),
    UNIQUE KEY uq_pages_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE contact_messages (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    message_code  VARCHAR(50) NOT NULL,
    full_name     NVARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL,
    phone         VARCHAR(15),
    subject       NVARCHAR(255),
    content       TEXT NOT NULL,
    status        ENUM('new','processing','resolved') DEFAULT 'new',
    admin_reply   TEXT,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_contact_messages_code (message_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- KHỐI 11: THÔNG BÁO & NHẬT KÝ HỆ THỐNG
-- ================================================================

CREATE TABLE notifications (
    id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    notification_code  VARCHAR(50) NOT NULL,
    user_code          VARCHAR(50) NOT NULL,
    title              NVARCHAR(255) NOT NULL,
    content            NVARCHAR(500),
    type               ENUM('order','promotion','system') DEFAULT 'system',
    reference_code     VARCHAR(50) COMMENT 'VD: order_code nếu type=order',
    is_read            BOOLEAN DEFAULT FALSE,
    created_at         DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_notifications_code (notification_code),
    FOREIGN KEY (user_code) REFERENCES users(user_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE admin_activity_logs (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    log_code      VARCHAR(50) NOT NULL,
    user_code     VARCHAR(50) NOT NULL COMMENT 'Admin/staff thực hiện thao tác',
    action        VARCHAR(100) NOT NULL COMMENT 'VD: create_product, update_order_status, delete_voucher',
    target_table  VARCHAR(100),
    target_code   VARCHAR(50),
    detail        TEXT,
    ip_address    VARCHAR(45),
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_admin_activity_logs_code (log_code),
    FOREIGN KEY (user_code) REFERENCES users(user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE newsletter_subscribers (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    subscriber_code  VARCHAR(50) NOT NULL,
    email            VARCHAR(150) NOT NULL,
    is_active        BOOLEAN DEFAULT TRUE,
    subscribed_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_newsletter_subscribers_code (subscriber_code),
    UNIQUE KEY uq_newsletter_subscribers_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE newsletter_campaigns (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    campaign_code   VARCHAR(50) NOT NULL,
    subject         NVARCHAR(255) NOT NULL,
    content         LONGTEXT NOT NULL,
    status          ENUM('draft','sending','sent','cancelled') NOT NULL DEFAULT 'draft',
    total_sent      INT UNSIGNED NOT NULL DEFAULT 0,
    scheduled_at    DATETIME DEFAULT NULL,
    sent_at         DATETIME DEFAULT NULL,
    created_by_code VARCHAR(50),
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_newsletter_campaigns_code (campaign_code),
    FOREIGN KEY (created_by_code) REFERENCES users(user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE system_settings (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    setting_code    VARCHAR(50) NOT NULL COMMENT 'Trước đây là setting_key',
    setting_value   TEXT NOT NULL,
    description     NVARCHAR(255),
    updated_by_code VARCHAR(50),
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_system_settings_code (setting_code),
    FOREIGN KEY (updated_by_code) REFERENCES users(user_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- TRIGGER
-- ================================================================

DELIMITER $$

CREATE TRIGGER trg_reviews_avg_rating
AFTER UPDATE ON reviews
FOR EACH ROW
BEGIN
    IF NEW.is_approved = TRUE AND (OLD.is_approved = FALSE OR OLD.rating <> NEW.rating) THEN
        UPDATE products
        SET avg_rating = (
            SELECT ROUND(AVG(rating), 1) FROM reviews
            WHERE product_code = NEW.product_code AND is_approved = TRUE
        )
        WHERE product_code = NEW.product_code;
    END IF;
END$$

CREATE TRIGGER trg_point_transactions_apply
AFTER INSERT ON point_transactions
FOR EACH ROW
BEGIN
    UPDATE users SET loyalty_points = GREATEST(0, loyalty_points + NEW.points)
    WHERE user_code = NEW.user_code;

    UPDATE users u
    SET u.tier_code = (
        SELECT tier_code FROM membership_tiers
        WHERE min_points <= u.loyalty_points
        ORDER BY min_points DESC LIMIT 1
    )
    WHERE u.user_code = NEW.user_code;
END$$

DELIMITER ;

-- ================================================================
-- INDEX BỔ SUNG CHO HIỆU NĂNG TRUY VẤN
-- ================================================================

CREATE INDEX idx_products_active_featured ON products(is_active, is_featured);
CREATE INDEX idx_orders_user_status ON orders(user_code, order_status);
CREATE INDEX idx_orders_created ON orders(created_at);
CREATE INDEX idx_orders_tracking ON orders(tracking_code);
CREATE INDEX idx_blog_posts_status_published ON blog_posts(status, published_at);
CREATE INDEX idx_reviews_product_approved ON reviews(product_code, is_approved);
CREATE INDEX idx_return_requests_status ON return_requests(status);
CREATE INDEX idx_notifications_user_read ON notifications(user_code, is_read);
CREATE INDEX idx_point_transactions_user ON point_transactions(user_code);
CREATE INDEX idx_admin_logs_user_created ON admin_activity_logs(user_code, created_at);
CREATE INDEX idx_stock_transfers_status ON stock_transfers(status);
CREATE INDEX idx_payment_tx_order_type ON payment_transactions(order_code, transaction_type);
CREATE INDEX idx_newsletter_campaigns_status ON newsletter_campaigns(status);
CREATE INDEX idx_categories_parent ON categories(parent_code);
CREATE INDEX idx_products_category ON products(category_code);
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse_code);

ALTER TABLE products ADD FULLTEXT INDEX ft_products_name (name, short_description);
ALTER TABLE products ADD FULLTEXT INDEX ft_products_description (description);
ALTER TABLE blog_posts ADD FULLTEXT INDEX ft_blog_title (title, excerpt);
ALTER TABLE blog_posts ADD FULLTEXT INDEX ft_blog_content (content);

-- ================================================================
-- DỮ LIỆU MẪU (SEED DATA)
-- ================================================================

INSERT INTO roles (role_code, role_name, description) VALUES
('admin', 'admin', 'Quản trị toàn hệ thống'),
('staff', 'staff', 'Nhân viên xử lý đơn hàng, kho, blog'),
('customer', 'customer', 'Khách hàng mua sắm');

INSERT INTO age_groups (age_group_code, name, min_month, max_month, display_order) VALUES
('me-bau', 'Mẹ bầu', NULL, NULL, 0),
('0-3m', 'Sơ sinh (0-3 tháng)', 0, 3, 1),
('3-6m', '3-6 tháng', 3, 6, 2),
('6-12m', '6-12 tháng', 6, 12, 3),
('1-3y', '1-3 tuổi', 12, 36, 4),
('3-6y', '3-6 tuổi', 36, 72, 5);

INSERT INTO categories (category_code, name, slug, display_order) VALUES
('cat-sua', 'Sữa & Dinh dưỡng', 'sua-dinh-duong', 1),
('cat-bim', 'Bỉm & Tã', 'bim-ta', 2),
('cat-so-sinh', 'Đồ dùng sơ sinh', 'do-dung-so-sinh', 3),
('cat-thoi-trang', 'Thời trang bé', 'thoi-trang-be', 4),
('cat-do-choi', 'Đồ chơi', 'do-choi', 5),
('cat-xe-day', 'Xe đẩy - Nôi cũi', 'xe-day-noi-cui', 6),
('cat-me', 'Chăm sóc mẹ', 'cham-soc-me', 7),
('cat-be', 'Chăm sóc bé', 'cham-soc-be', 8);

INSERT INTO shipping_methods (shipping_method_code, name, base_fee, estimated_days, display_order) VALUES
('standard', 'Giao hàng tiêu chuẩn', 20000, '3-5 ngày', 1),
('express', 'Giao hàng nhanh', 35000, '1-2 ngày', 2),
('same_day', 'Giao hàng hỏa tốc nội thành', 50000, 'Trong ngày', 3);

INSERT INTO payment_methods (payment_method_code, name, method_type, display_order) VALUES
('cod', 'Thanh toán khi nhận hàng (COD)', 'cod', 1),
('bank_transfer', 'Chuyển khoản ngân hàng', 'bank_transfer', 2),
('momo', 'Ví Momo', 'ewallet', 3),
('zalopay', 'ZaloPay', 'ewallet', 4),
('vnpay', 'VNPay', 'gateway', 5);

INSERT INTO permissions (permission_code, module_name, description) VALUES
('users.manage', 'Người dùng', 'Xem/khóa/mở khóa tài khoản'),
('roles.manage', 'Phân quyền', 'Gán vai trò và quyền module'),
('products.manage', 'Sản phẩm', 'Quản lý danh mục, thương hiệu, sản phẩm, biến thể'),
('inventory.manage', 'Kho', 'Nhập/xuất/điều chỉnh/chuyển kho'),
('orders.manage', 'Đơn hàng', 'Xác nhận, đóng gói, vận chuyển, hủy đơn'),
('returns.manage', 'Đổi trả', 'Duyệt và xử lý đổi/trả hàng'),
('promotions.manage', 'Khuyến mãi', 'Voucher, flash sale'),
('payments.manage', 'Thanh toán', 'Đối soát giao dịch, hoàn tiền'),
('content.manage', 'Nội dung', 'Blog, banner, trang tĩnh, newsletter'),
('reports.view', 'Báo cáo', 'Xem thống kê doanh thu/kho/khách hàng'),
('settings.manage', 'Cấu hình', 'Cấu hình hệ thống, PTTT, vận chuyển'),
('support.manage', 'CSKH', 'Liên hệ, phản hồi đánh giá');

INSERT INTO role_permissions (role_code, permission_code)
SELECT 'admin', permission_code FROM permissions;

INSERT INTO role_permissions (role_code, permission_code)
SELECT 'staff', permission_code FROM permissions
WHERE permission_code IN (
    'products.manage', 'inventory.manage', 'orders.manage', 'returns.manage',
    'promotions.manage', 'content.manage', 'reports.view', 'support.manage', 'payments.manage'
);

INSERT INTO system_settings (setting_code, setting_value, description) VALUES
('shop_name', 'BabyShop', 'Tên cửa hàng hiển thị'),
('shop_email', 'support@babyshop.vn', 'Email liên hệ / gửi thông báo'),
('shop_phone', '1900xxxx', 'Số điện thoại hỗ trợ'),
('shop_address', 'Hà Nội, Việt Nam', 'Địa chỉ cửa hàng'),
('return_window_days', '7', 'Số ngày cho phép đổi/trả sau khi delivered'),
('points_earn_rate', '1000', 'Số VNĐ để tích 1 điểm (VD 1000 = 1 điểm / 1000đ)'),
('points_redeem_rate', '1', '1 điểm quy đổi thành bao nhiêu VNĐ'),
('points_redeem_min', '100', 'Số điểm tối thiểu để được quy đổi'),
('points_expire_months', '12', 'Số tháng điểm hết hạn kể từ lần earn (0 = không hết hạn)'),
('discount_stacking_policy', 'voucher_then_tier_then_points', 'Thứ tự cộng dồn: voucher → hạng TV → điểm'),
('max_points_discount_percent', '50', 'Điểm quy đổi tối đa % trên (subtotal - voucher - membership)'),
('free_shipping_min_order', '300000', 'Ngưỡng miễn phí ship mặc định (có thể bị ghi đè bởi hạng TV)'),
('order_auto_cancel_unpaid_hours', '24', 'Hủy đơn online chưa thanh toán sau N giờ'),
('low_stock_default_threshold', '5', 'Ngưỡng cảnh báo tồn kho mặc định'),
('review_auto_approve', 'false', 'Tự duyệt đánh giá hay cần admin duyệt');

INSERT INTO blog_categories (blog_category_code, name, slug, display_order) VALUES
('blog-cham-con', 'Kinh nghiệm chăm con', 'kinh-nghiem-cham-con', 1),
('blog-dinh-duong', 'Dinh dưỡng cho bé', 'dinh-duong-cho-be', 2),
('blog-mang-thai', 'Mang thai & Sinh nở', 'mang-thai-sinh-no', 3),
('blog-review', 'Review sản phẩm', 'review-san-pham', 4),
('blog-meo-vat', 'Mẹo vặt gia đình', 'meo-vat-gia-dinh', 5);

INSERT INTO membership_tiers (tier_code, name, min_points, discount_percent, benefits, display_order) VALUES
('member', 'Thành viên', 0, 0, 'Tích điểm cho mỗi đơn hàng', 1),
('silver', 'Bạc', 500, 2, 'Giảm 2% mọi đơn, ưu tiên hỗ trợ', 2),
('gold', 'Vàng', 2000, 5, 'Giảm 5% mọi đơn, freeship đơn từ 300k', 3),
('diamond', 'Kim cương', 5000, 8, 'Giảm 8% mọi đơn, freeship toàn bộ, quà sinh nhật', 4);

INSERT INTO pages (page_code, title, slug, content, is_active) VALUES
('page-gioi-thieu', 'Giới thiệu', 'gioi-thieu', 'Nội dung giới thiệu về shop...', TRUE),
('page-doi-tra', 'Chính sách đổi trả', 'chinh-sach-doi-tra', 'Nội dung chính sách đổi trả...', TRUE),
('page-dieu-khoan', 'Điều khoản sử dụng', 'dieu-khoan-su-dung', 'Nội dung điều khoản...', TRUE),
('page-van-chuyen', 'Chính sách vận chuyển', 'chinh-sach-van-chuyen', 'Nội dung chính sách vận chuyển...', TRUE),
('page-bao-mat', 'Chính sách bảo mật', 'chinh-sach-bao-mat', 'Nội dung chính sách bảo mật...', TRUE);