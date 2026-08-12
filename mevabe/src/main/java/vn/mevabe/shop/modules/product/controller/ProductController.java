package vn.mevabe.shop.modules.product.controller;

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
import vn.mevabe.shop.modules.product.dto.ProductRequest;
import vn.mevabe.shop.modules.product.dto.ProductResponse;
import vn.mevabe.shop.modules.product.service.ProductService;

/**
 * REST controller cho san pham. Base path day du: /api/v1/products
 */
@Tag(name = "Products", description = "Quan ly san pham")
@RestController
@RequestMapping("/v1/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @Operation(summary = "Danh sach san pham (phan trang + loc)")
    @GetMapping
    public ApiResponse<PageResponse<ProductResponse>> search(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String categoryCode,
            @RequestParam(required = false) Boolean isActive,
            @RequestParam(required = false) Boolean isFeatured,
            @PageableDefault(size = 20) Pageable pageable) {
        return ApiResponse.success(
                productService.search(keyword, categoryCode, isActive, isFeatured, pageable));
    }

    @Operation(summary = "Chi tiet san pham theo ma")
    @GetMapping("/{code}")
    public ApiResponse<ProductResponse> getByCode(@PathVariable("code") String code) {
        return ApiResponse.success(productService.getByCode(code));
    }

    @Operation(summary = "Tao san pham moi")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<ProductResponse> create(@Valid @RequestBody ProductRequest request) {
        return ApiResponse.success(productService.create(request), "Tao san pham thanh cong");
    }

    @Operation(summary = "Cap nhat san pham")
    @PutMapping("/{code}")
    public ApiResponse<ProductResponse> update(@PathVariable("code") String code,
                                               @Valid @RequestBody ProductRequest request) {
        return ApiResponse.success(productService.update(code, request), "Cap nhat thanh cong");
    }

    @Operation(summary = "Xoa san pham")
    @DeleteMapping("/{code}")
    public ApiResponse<Void> delete(@PathVariable("code") String code) {
        productService.delete(code);
        return ApiResponse.success(null, "Xoa thanh cong");
    }
}
