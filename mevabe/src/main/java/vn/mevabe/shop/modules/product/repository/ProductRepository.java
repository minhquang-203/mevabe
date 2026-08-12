package vn.mevabe.shop.modules.product.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.mevabe.shop.modules.product.entity.Product;

import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long> {

    Optional<Product> findByProductCode(String productCode);

    boolean existsBySku(String sku);

    boolean existsBySlug(String slug);

    @Query("SELECT p FROM Product p WHERE " +
            "(:keyword IS NULL OR LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%'))) AND " +
            "(:categoryCode IS NULL OR p.categoryCode = :categoryCode) AND " +
            "(:isActive IS NULL OR p.isActive = :isActive) AND " +
            "(:isFeatured IS NULL OR p.isFeatured = :isFeatured)")
    Page<Product> search(@Param("keyword") String keyword,
                         @Param("categoryCode") String categoryCode,
                         @Param("isActive") Boolean isActive,
                         @Param("isFeatured") Boolean isFeatured,
                         Pageable pageable);
}
