package vn.mevabe.shop.modules.category.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import vn.mevabe.shop.common.entity.BaseEntity;

/**
 * Anh xa bang `categories` trong DB.
 * Ke thua BaseEntity de co san id + created_at + updated_at.
 *
 * Luu y: DB dung *_code lam khoa nghiep vu. O day ta anh xa parent_code
 * dang chuoi cho don gian (khong lam quan he tu tham chieu phuc tap).
 */
@Entity
@Table(name = "categories")
@Getter
@Setter
@NoArgsConstructor
public class Category extends BaseEntity {

    @Column(name = "category_code", nullable = false, length = 50, updatable = false)
    private String categoryCode;

    @Column(name = "parent_code", length = 50)
    private String parentCode;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "slug", nullable = false, length = 120)
    private String slug;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "display_order")
    private Integer displayOrder;

    @Column(name = "is_active")
    private Boolean isActive;
}
