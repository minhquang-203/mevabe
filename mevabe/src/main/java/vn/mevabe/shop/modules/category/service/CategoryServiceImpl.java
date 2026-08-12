package vn.mevabe.shop.modules.category.service;

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
import vn.mevabe.shop.modules.category.dto.CategoryRequest;
import vn.mevabe.shop.modules.category.dto.CategoryResponse;
import vn.mevabe.shop.modules.category.entity.Category;
import vn.mevabe.shop.modules.category.mapper.CategoryMapper;
import vn.mevabe.shop.modules.category.repository.CategoryRepository;

import java.time.Duration;

/**
 * Tang nghiep vu (business logic) cua Category.
 *
 * DIEM DANG CHU Y (mau de nhan ban cho module khac):
 *  - Dung CacheService (port) de cache -> khong biet la Redis hay memory.
 *  - Dung EventPublisher (port) de phat su kien -> khong biet la log hay Kafka.
 *  - Nem AppException voi ErrorCode -> GlobalExceptionHandler lo phan tra loi.
 *  - @Transactional cho cac thao tac ghi.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;
    private final CategoryMapper categoryMapper;
    private final CacheService cacheService;
    private final EventPublisher eventPublisher;

    private static final String CACHE_PREFIX = "category:";
    private static final Duration CACHE_TTL = Duration.ofMinutes(5);

    @Override
    @Transactional(readOnly = true)
    public PageResponse<CategoryResponse> search(String keyword, Boolean isActive, Pageable pageable) {
        Page<Category> page = categoryRepository.search(
                (keyword == null || keyword.isBlank()) ? null : keyword.trim(),
                isActive,
                pageable
        );
        return PageResponse.of(page, categoryMapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public CategoryResponse getByCode(String categoryCode) {
        // 1) Thu lay tu cache truoc
        var cached = cacheService.get(CACHE_PREFIX + categoryCode, CategoryResponse.class);
        if (cached.isPresent()) {
            return cached.get();
        }
        // 2) Khong co thi lay tu DB
        Category category = findEntityOrThrow(categoryCode);
        CategoryResponse response = categoryMapper.toResponse(category);
        // 3) Ghi vao cache cho lan sau
        cacheService.put(CACHE_PREFIX + categoryCode, response, CACHE_TTL);
        return response;
    }

    @Override
    @Transactional
    public CategoryResponse create(CategoryRequest request) {
        if (categoryRepository.existsBySlug(request.slug())) {
            throw new AppException(ErrorCode.RESOURCE_ALREADY_EXISTS, "Slug da ton tai: " + request.slug());
        }
        Category category = new Category();
        category.setCategoryCode(CodeGenerator.generate("CAT"));
        categoryMapper.applyRequest(category, request);

        Category saved = categoryRepository.save(category);

        // Phat su kien -> he thong khac (search index, cache warmup...) co the lang nghe
        eventPublisher.publish(DomainEvent.of("CategoryCreated", saved.getCategoryCode(),
                categoryMapper.toResponse(saved)));

        return categoryMapper.toResponse(saved);
    }

    @Override
    @Transactional
    public CategoryResponse update(String categoryCode, CategoryRequest request) {
        Category category = findEntityOrThrow(categoryCode);
        categoryMapper.applyRequest(category, request);
        Category saved = categoryRepository.save(category);

        cacheService.evict(CACHE_PREFIX + categoryCode);
        eventPublisher.publish(DomainEvent.of("CategoryUpdated", categoryCode,
                categoryMapper.toResponse(saved)));

        return categoryMapper.toResponse(saved);
    }

    @Override
    @Transactional
    public void delete(String categoryCode) {
        Category category = findEntityOrThrow(categoryCode);
        categoryRepository.delete(category);

        cacheService.evict(CACHE_PREFIX + categoryCode);
        eventPublisher.publish(DomainEvent.of("CategoryDeleted", categoryCode, null));
    }

    private Category findEntityOrThrow(String categoryCode) {
        return categoryRepository.findByCategoryCode(categoryCode)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND,
                        "Khong tim thay danh muc: " + categoryCode));
    }
}
