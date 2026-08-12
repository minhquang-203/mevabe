package vn.mevabe.shop.common.response;

import lombok.Builder;
import lombok.Getter;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.function.Function;

/**
 * Dinh dang phan trang chuan cho danh sach.
 * Tach roi khoi Page cua Spring de response gon gang, on dinh.
 */
@Getter
@Builder
public class PageResponse<T> {

    private final List<T> items;
    private final int page;
    private final int size;
    private final long totalItems;
    private final int totalPages;
    private final boolean hasNext;
    private final boolean hasPrevious;

    /**
     * Chuyen doi tu Page<Entity> sang PageResponse<Dto> qua ham mapper.
     */
    public static <E, D> PageResponse<D> of(Page<E> page, Function<E, D> mapper) {
        return PageResponse.<D>builder()
                .items(page.getContent().stream().map(mapper).toList())
                .page(page.getNumber())
                .size(page.getSize())
                .totalItems(page.getTotalElements())
                .totalPages(page.getTotalPages())
                .hasNext(page.hasNext())
                .hasPrevious(page.hasPrevious())
                .build();
    }
}
