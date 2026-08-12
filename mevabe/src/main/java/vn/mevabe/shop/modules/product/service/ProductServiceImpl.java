package vn.mevabe.shop.modules.product.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.mevabe.shop.common.exception.AppException;
import vn.mevabe.shop.common.exception.ErrorCode;
import vn.mevabe.shop.common.response.PageResponse;
import vn.mevabe.shop.common.util.CodeGenerator;
import vn.mevabe.shop.infrastructure.cache.CacheService;
import vn.mevabe.shop.infrastructure.messaging.DomainEvent;
import vn.mevabe.shop.infrastructure.messaging.EventPublisher;
import vn.mevabe.shop.modules.product.dto.ProductRequest;
import vn.mevabe.shop.modules.product.dto.ProductResponse;
import vn.mevabe.shop.modules.product.entity.Product;
import vn.mevabe.shop.modules.product.mapper.ProductMapper;
import vn.mevabe.shop.modules.product.repository.ProductRepository;

import java.time.Duration;

/**
 * Tang nghiep vu cua Product. Cung khuon voi CategoryServiceImpl:
 * dung CacheService/EventPublisher (port), nem AppException, @Transactional.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final ProductMapper productMapper;
    private final CacheService cacheService;
    private final EventPublisher eventPublisher;

    private static final String CACHE_PREFIX = "product:";
    private static final Duration CACHE_TTL = Duration.ofMinutes(5);

    @Override
    @Transactional(readOnly = true)
    public PageResponse<ProductResponse> search(String keyword, String categoryCode,
                                                Boolean isActive, Boolean isFeatured, Pageable pageable) {
        Page<Product> page = productRepository.search(
                (keyword == null || keyword.isBlank()) ? null : keyword.trim(),
                (categoryCode == null || categoryCode.isBlank()) ? null : categoryCode.trim(),
                isActive,
                isFeatured,
                pageable
        );
        return PageResponse.of(page, productMapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public ProductResponse getByCode(String productCode) {
        var cached = cacheService.get(CACHE_PREFIX + productCode, ProductResponse.class);
        if (cached.isPresent()) {
            return cached.get();
        }
        Product product = findEntityOrThrow(productCode);
        ProductResponse response = productMapper.toResponse(product);
        cacheService.put(CACHE_PREFIX + productCode, response, CACHE_TTL);
        return response;
    }

    @Override
    @Transactional
    public ProductResponse create(ProductRequest request) {
        if (productRepository.existsBySku(request.sku())) {
            throw new AppException(ErrorCode.RESOURCE_ALREADY_EXISTS, "SKU da ton tai: " + request.sku());
        }
        if (productRepository.existsBySlug(request.slug())) {
            throw new AppException(ErrorCode.RESOURCE_ALREADY_EXISTS, "Slug da ton tai: " + request.slug());
        }
        Product product = new Product();
        product.setProductCode(CodeGenerator.generate("PRD"));
        productMapper.applyRequest(product, request);

        Product saved = productRepository.save(product);
        eventPublisher.publish(DomainEvent.of("ProductCreated", saved.getProductCode(),
                productMapper.toResponse(saved)));

        return productMapper.toResponse(saved);
    }

    @Override
    @Transactional
    public ProductResponse update(String productCode, ProductRequest request) {
        Product product = findEntityOrThrow(productCode);
        productMapper.applyRequest(product, request);
        Product saved = productRepository.save(product);

        cacheService.evict(CACHE_PREFIX + productCode);
        eventPublisher.publish(DomainEvent.of("ProductUpdated", productCode,
                productMapper.toResponse(saved)));

        return productMapper.toResponse(saved);
    }

    @Override
    @Transactional
    public void delete(String productCode) {
        Product product = findEntityOrThrow(productCode);
        productRepository.delete(product);

        cacheService.evict(CACHE_PREFIX + productCode);
        eventPublisher.publish(DomainEvent.of("ProductDeleted", productCode, null));
    }

    private Product findEntityOrThrow(String productCode) {
        return productRepository.findByProductCode(productCode)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND,
                        "Khong tim thay san pham: " + productCode));
    }
}
