package vn.mevabe.shop.modules.product.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

/**
 * Du lieu client gui len khi tao/sua san pham (chi cac truong duoc phep sua).
 * Cac truong he thong (view_count, sold_count, avg_rating, product_code) khong nam o day.
 */
public record ProductRequest(

        @NotBlank(message = "Ma danh muc khong duoc de trong")
        @Size(max = 50)
        String categoryCode,

        @Size(max = 50)
        String brandCode,

        @NotBlank(message = "SKU khong duoc de trong")
        @Size(max = 50)
        String sku,

        @NotBlank(message = "Ten san pham khong duoc de trong")
        @Size(max = 255)
        String name,

        @NotBlank(message = "Slug khong duoc de trong")
        @Size(max = 280)
        String slug,

        @Size(max = 500)
        String shortDescription,

        String description,

        @Size(max = 100)
        String originCountry,

        @Size(max = 10)
        String genderTarget,

        @NotNull(message = "Gia ban khong duoc de trong")
        @DecimalMin(value = "0", message = "Gia ban phai >= 0")
        BigDecimal basePrice,

        BigDecimal salePrice,

        BigDecimal costPrice,

        Integer weightGram,

        Boolean isFeatured,

        Boolean isActive,

        @Size(max = 255)
        String metaTitle,

        @Size(max = 500)
        String metaDescription
) {
}
