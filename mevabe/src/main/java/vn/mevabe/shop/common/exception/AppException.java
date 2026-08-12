package vn.mevabe.shop.common.exception;

import lombok.Getter;

/**
 * Exception nghiep vu duy nhat cua ung dung.
 * Nem loi bang: throw new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Khong thay category ABC");
 */
@Getter
public class AppException extends RuntimeException {

    private final ErrorCode errorCode;

    public AppException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }

    public AppException(ErrorCode errorCode, String customMessage) {
        super(customMessage);
        this.errorCode = errorCode;
    }
}
