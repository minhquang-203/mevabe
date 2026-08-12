package vn.mevabe.shop.modules.product.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import vn.mevabe.shop.common.entity.BaseEntity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Anh xa bang `products`.
 * Cac ma tham chieu (category_code, brand_code) de dang chuoi cho don gian.
 */
@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
public class Product extends BaseEntity {

    @Column(name = "product_code", nullable = false, length = 50, updatable = false)
    private String productCode;

    @Column(name = "category_code", nullable = false, length = 50)
    private String categoryCode;

    @Column(name = "brand_code", length = 50)
    private String brandCode;

    @Column(name = "sku", nullable = false, length = 50)
    private String sku;

    @Column(name = "name", nullable = false, length = 255)
    private String name;

    @Column(name = "slug", nullable = false, length = 280)
    private String slug;

    @Column(name = "short_description", length = 500)
    private String shortDescription;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "origin_country", length = 100)
    private String originCountry;

    @Column(name = "gender_target", length = 10)
    private String genderTarget;

    @Column(name = "base_price", nullable = false)
    private BigDecimal basePrice;

    @Column(name = "sale_price")
    private BigDecimal salePrice;

    @Column(name = "sale_price_start")
    private LocalDateTime salePriceStart;

    @Column(name = "sale_price_end")
    private LocalDateTime salePriceEnd;

    @Column(name = "cost_price")
    private BigDecimal costPrice;

    @Column(name = "weight_gram")
    private Integer weightGram;

    @Column(name = "is_featured")
    private Boolean isFeatured;

    @Column(name = "is_active")
    private Boolean isActive;

    @Column(name = "view_count", insertable = false, updatable = false)
    private Long viewCount;

    @Column(name = "sold_count", insertable = false, updatable = false)
    private Long soldCount;

    @Column(name = "avg_rating", insertable = false, updatable = false)
    private BigDecimal avgRating;

    @Column(name = "meta_title", length = 255)
    private String metaTitle;

    @Column(name = "meta_description", length = 500)
    private String metaDescription;
}
