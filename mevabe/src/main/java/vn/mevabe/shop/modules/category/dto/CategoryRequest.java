package vn.mevabe.shop.modules.category.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Du lieu client gui len khi tao/sua danh muc.
 * Dung Bean Validation de tu dong kiem tra dau vao.
 */
public record CategoryRequest(

        @NotBlank(message = "Ten danh muc khong duoc de trong")
        @Size(max = 100, message = "Ten toi da 100 ky tu")
        String name,

        @NotBlank(message = "Slug khong duoc de trong")
        @Size(max = 120, message = "Slug toi da 120 ky tu")
        String slug,

        @Size(max = 50, message = "Ma danh muc cha toi da 50 ky tu")
        String parentCode,

        @Size(max = 500, message = "Duong dan anh toi da 500 ky tu")
        String imageUrl,

        String description,

        Integer displayOrder,

        Boolean isActive
) {
}
