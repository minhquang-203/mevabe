package vn.mevabe.shop.modules.category.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import vn.mevabe.shop.common.response.ApiResponse;
import vn.mevabe.shop.common.response.PageResponse;
import vn.mevabe.shop.modules.category.dto.CategoryRequest;
import vn.mevabe.shop.modules.category.dto.CategoryResponse;
import vn.mevabe.shop.modules.category.service.CategoryService;

/**
 * Tang REST controller. Chi lam nhiem vu: nhan request -> goi service -> tra ApiResponse.
 * KHONG chua business logic o day.
 *
 * Base path day du: /api/v1/categories (context-path /api + /v1/categories)
 */
@Tag(name = "Categories", description = "Quan ly danh muc san pham")
@RestController
@RequestMapping("/v1/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @Operation(summary = "Danh sach danh muc (co phan trang + tim kiem)")
    @GetMapping
    public ApiResponse<PageResponse<CategoryResponse>> search(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Boolean isActive,
            @PageableDefault(size = 20) Pageable pageable) {
        return ApiResponse.success(categoryService.search(keyword, isActive, pageable));
    }

    @Operation(summary = "Chi tiet danh muc theo ma")
    @GetMapping("/{code}")
    public ApiResponse<CategoryResponse> getByCode(@PathVariable("code") String code) {
        return ApiResponse.success(categoryService.getByCode(code));
    }

    @Operation(summary = "Tao danh muc moi")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<CategoryResponse> create(@Valid @RequestBody CategoryRequest request) {
        return ApiResponse.success(categoryService.create(request), "Tao danh muc thanh cong");
    }

    @Operation(summary = "Cap nhat danh muc")
    @PutMapping("/{code}")
    public ApiResponse<CategoryResponse> update(@PathVariable("code") String code,
                                                @Valid @RequestBody CategoryRequest request) {
        return ApiResponse.success(categoryService.update(code, request), "Cap nhat thanh cong");
    }

    @Operation(summary = "Xoa danh muc")
    @DeleteMapping("/{code}")
    public ApiResponse<Void> delete(@PathVariable("code") String code) {
        categoryService.delete(code);
        return ApiResponse.success(null, "Xoa thanh cong");
    }
}
