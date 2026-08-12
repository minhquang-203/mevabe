package vn.mevabe.shop.common.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

/**
 * Danh sach ma loi nghiep vu tap trung.
 * Them loi moi = them 1 dong o day, khong rai rac khap noi.
 */
@Getter
public enum ErrorCode {

    // Chung
    INTERNAL_ERROR("INTERNAL_ERROR", "Loi he thong, vui long thu lai sau", HttpStatus.INTERNAL_SERVER_ERROR),
    VALIDATION_ERROR("VALIDATION_ERROR", "Du lieu khong hop le", HttpStatus.BAD_REQUEST),
    RESOURCE_NOT_FOUND("RESOURCE_NOT_FOUND", "Khong tim thay du lieu", HttpStatus.NOT_FOUND),
    RESOURCE_ALREADY_EXISTS("RESOURCE_ALREADY_EXISTS", "Du lieu da ton tai", HttpStatus.CONFLICT),

    // Xac thuc / phan quyen
    UNAUTHORIZED("UNAUTHORIZED", "Chua dang nhap hoac phien het han", HttpStatus.UNAUTHORIZED),
    FORBIDDEN("FORBIDDEN", "Khong co quyen truy cap", HttpStatus.FORBIDDEN),

    // Nghiep vu (vi du - bo sung dan)
    OUT_OF_STOCK("OUT_OF_STOCK", "San pham da het hang", HttpStatus.BAD_REQUEST),
    INVALID_VOUCHER("INVALID_VOUCHER", "Ma giam gia khong hop le", HttpStatus.BAD_REQUEST);

    private final String code;
    private final String message;
    private final HttpStatus status;

    ErrorCode(String code, String message, HttpStatus status) {
        this.code = code;
        this.message = message;
        this.status = status;
    }
}
