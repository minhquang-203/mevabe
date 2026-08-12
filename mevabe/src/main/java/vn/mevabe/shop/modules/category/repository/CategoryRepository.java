package vn.mevabe.shop.modules.category.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.mevabe.shop.modules.category.entity.Category;

import java.util.Optional;

/**
 * Tang truy cap DB. Spring Data JPA tu sinh cau lenh tu ten phuong thuc.
 */
public interface CategoryRepository extends JpaRepository<Category, Long> {

    Optional<Category> findByCategoryCode(String categoryCode);

    boolean existsBySlug(String slug);

    boolean existsByCategoryCode(String categoryCode);

    @Query("SELECT c FROM Category c WHERE " +
            "(:keyword IS NULL OR LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%'))) AND " +
            "(:isActive IS NULL OR c.isActive = :isActive)")
    org.springframework.data.domain.Page<Category> search(@Param("keyword") String keyword,
                                                          @Param("isActive") Boolean isActive,
                                                          org.springframework.data.domain.Pageable pageable);
}
