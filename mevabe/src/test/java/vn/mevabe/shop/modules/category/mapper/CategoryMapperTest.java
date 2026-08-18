package vn.mevabe.shop.modules.category.mapper;

import org.junit.jupiter.api.Test;
import vn.mevabe.shop.modules.category.dto.CategoryRequest;
import vn.mevabe.shop.modules.category.dto.CategoryResponse;
import vn.mevabe.shop.modules.category.entity.Category;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class CategoryMapperTest {

    private final CategoryMapper mapper = new CategoryMapper();

    @Test
    void toResponse_copiesFieldsFromEntity() {
        LocalDateTime now = LocalDateTime.of(2026, 8, 18, 10, 0);
        Category entity = new Category();
        entity.setId(7L);
        entity.setCategoryCode("CAT-20260818-AB12");
        entity.setParentCode("CAT-ROOT");
        entity.setName("Sữa bột");
        entity.setSlug("sua-bot");
        entity.setImageUrl("https://example.com/sua.png");
        entity.setDescription("Sữa cho bé");
        entity.setDisplayOrder(3);
        entity.setIsActive(true);
        entity.setCreatedAt(now);
        entity.setUpdatedAt(now);

        CategoryResponse res = mapper.toResponse(entity);

        assertThat(res.id()).isEqualTo(7L);
        assertThat(res.categoryCode()).isEqualTo("CAT-20260818-AB12");
        assertThat(res.parentCode()).isEqualTo("CAT-ROOT");
        assertThat(res.name()).isEqualTo("Sữa bột");
        assertThat(res.slug()).isEqualTo("sua-bot");
        assertThat(res.imageUrl()).isEqualTo("https://example.com/sua.png");
        assertThat(res.description()).isEqualTo("Sữa cho bé");
        assertThat(res.displayOrder()).isEqualTo(3);
        assertThat(res.isActive()).isTrue();
        assertThat(res.createdAt()).isEqualTo(now);
        assertThat(res.updatedAt()).isEqualTo(now);
    }

    @Test
    void applyRequest_setsDefaultsAndDoesNotTouchCategoryCode() {
        Category target = new Category();
        target.setCategoryCode("CAT-KEEP");

        CategoryRequest req = new CategoryRequest(
                "Tã",
                "ta",
                null,
                null,
                null,
                null,
                null
        );

        mapper.applyRequest(target, req);

        assertThat(target.getName()).isEqualTo("Tã");
        assertThat(target.getSlug()).isEqualTo("ta");
        assertThat(target.getDisplayOrder()).isZero();
        assertThat(target.getIsActive()).isTrue();
        assertThat(target.getCategoryCode()).isEqualTo("CAT-KEEP");
    }
}
