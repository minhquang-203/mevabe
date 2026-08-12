package vn.mevabe.shop.modules.product.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ProductResponse(
        Long id,
        String productCode,
        String categoryCode,
        String brandCode,
        String sku,
        String name,
        String slug,
        String shortDescription,
        String description,
        String originCountry,
        String genderTarget,
        BigDecimal basePrice,
        BigDecimal salePrice,
        LocalDateTime salePriceStart,
        LocalDateTime salePriceEnd,
        BigDecimal costPrice,
        Integer weightGram,
        Boolean isFeatured,
        Boolean isActive,
        Long viewCount,
        Long soldCount,
        BigDecimal avgRating,
        String metaTitle,
        String metaDescription,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
