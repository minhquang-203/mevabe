package vn.mevabe.shop.modules.category.dto;

import java.time.LocalDateTime;

/**
 * Du lieu tra ve client. KHONG tra thang entity ra ngoai
 * (tranh lo cot nhay cam / vong lap quan he).
 */
public record CategoryResponse(
        Long id,
        String categoryCode,
        String parentCode,
        String name,
        String slug,
        String imageUrl,
        String description,
        Integer displayOrder,
        Boolean isActive,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
