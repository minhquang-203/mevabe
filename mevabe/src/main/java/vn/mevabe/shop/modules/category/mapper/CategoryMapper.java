package vn.mevabe.shop.modules.category.mapper;

import org.springframework.stereotype.Component;
import vn.mevabe.shop.modules.category.dto.CategoryRequest;
import vn.mevabe.shop.modules.category.dto.CategoryResponse;
import vn.mevabe.shop.modules.category.entity.Category;

/**
 * Chuyen doi giua Entity <-> DTO. Tach rieng cho gon service.
 * (Co the thay bang MapStruct sau nay neu muon.)
 */
@Component
public class CategoryMapper {

    public CategoryResponse toResponse(Category c) {
        return new CategoryResponse(
                c.getId(),
                c.getCategoryCode(),
                c.getParentCode(),
                c.getName(),
                c.getSlug(),
                c.getImageUrl(),
                c.getDescription(),
                c.getDisplayOrder(),
                c.getIsActive(),
                c.getCreatedAt(),
                c.getUpdatedAt()
        );
    }

    /**
     * Gan du lieu tu request vao entity (dung cho ca tao moi va cap nhat).
     * Khong dung toi categoryCode vi day la khoa nghiep vu, tao 1 lan.
     */
    public void applyRequest(Category target, CategoryRequest req) {
        target.setName(req.name());
        target.setSlug(req.slug());
        target.setParentCode(req.parentCode());
        target.setImageUrl(req.imageUrl());
        target.setDescription(req.description());
        target.setDisplayOrder(req.displayOrder() != null ? req.displayOrder() : 0);
        target.setIsActive(req.isActive() != null ? req.isActive() : Boolean.TRUE);
    }
}
