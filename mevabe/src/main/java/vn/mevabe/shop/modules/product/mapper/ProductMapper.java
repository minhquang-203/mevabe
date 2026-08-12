package vn.mevabe.shop.modules.product.mapper;

import org.springframework.stereotype.Component;
import vn.mevabe.shop.modules.product.dto.ProductRequest;
import vn.mevabe.shop.modules.product.dto.ProductResponse;
import vn.mevabe.shop.modules.product.entity.Product;

@Component
public class ProductMapper {

    public ProductResponse toResponse(Product p) {
        return new ProductResponse(
                p.getId(),
                p.getProductCode(),
                p.getCategoryCode(),
                p.getBrandCode(),
                p.getSku(),
                p.getName(),
                p.getSlug(),
                p.getShortDescription(),
                p.getDescription(),
                p.getOriginCountry(),
                p.getGenderTarget(),
                p.getBasePrice(),
                p.getSalePrice(),
                p.getSalePriceStart(),
                p.getSalePriceEnd(),
                p.getCostPrice(),
                p.getWeightGram(),
                p.getIsFeatured(),
                p.getIsActive(),
                p.getViewCount(),
                p.getSoldCount(),
                p.getAvgRating(),
                p.getMetaTitle(),
                p.getMetaDescription(),
                p.getCreatedAt(),
                p.getUpdatedAt()
        );
    }

    /**
     * Gan du lieu tu request vao entity (dung cho ca tao moi va cap nhat).
     * Khong dung toi productCode (khoa nghiep vu, tao 1 lan).
     */
    public void applyRequest(Product target, ProductRequest req) {
        target.setCategoryCode(req.categoryCode());
        target.setBrandCode(req.brandCode());
        target.setSku(req.sku());
        target.setName(req.name());
        target.setSlug(req.slug());
        target.setShortDescription(req.shortDescription());
        target.setDescription(req.description());
        target.setOriginCountry(req.originCountry());
        target.setGenderTarget(req.genderTarget() != null ? req.genderTarget() : "unisex");
        target.setBasePrice(req.basePrice());
        target.setSalePrice(req.salePrice());
        target.setCostPrice(req.costPrice());
        target.setWeightGram(req.weightGram());
        target.setIsFeatured(req.isFeatured() != null ? req.isFeatured() : Boolean.FALSE);
        target.setIsActive(req.isActive() != null ? req.isActive() : Boolean.TRUE);
        target.setMetaTitle(req.metaTitle());
        target.setMetaDescription(req.metaDescription());
    }
}
