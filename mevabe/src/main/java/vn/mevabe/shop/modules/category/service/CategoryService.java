package vn.mevabe.shop.modules.category.service;

import org.springframework.data.domain.Pageable;
import vn.mevabe.shop.common.response.PageResponse;
import vn.mevabe.shop.modules.category.dto.CategoryRequest;
import vn.mevabe.shop.modules.category.dto.CategoryResponse;

/**
 * Hop dong (interface) cua tang nghiep vu.
 * Controller phu thuoc interface nay, de test va thay the implementation.
 */
public interface CategoryService {

    PageResponse<CategoryResponse> search(String keyword, Boolean isActive, Pageable pageable);

    CategoryResponse getByCode(String categoryCode);

    CategoryResponse create(CategoryRequest request);

    CategoryResponse update(String categoryCode, CategoryRequest request);

    void delete(String categoryCode);
}
