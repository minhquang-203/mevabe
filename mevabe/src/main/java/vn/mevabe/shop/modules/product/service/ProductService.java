package vn.mevabe.shop.modules.product.service;

import org.springframework.data.domain.Pageable;
import vn.mevabe.shop.common.response.PageResponse;
import vn.mevabe.shop.modules.product.dto.ProductRequest;
import vn.mevabe.shop.modules.product.dto.ProductResponse;

public interface ProductService {

    PageResponse<ProductResponse> search(String keyword, String categoryCode,
                                         Boolean isActive, Boolean isFeatured, Pageable pageable);

    ProductResponse getByCode(String productCode);

    ProductResponse create(ProductRequest request);

    ProductResponse update(String productCode, ProductRequest request);

    void delete(String productCode);
}
