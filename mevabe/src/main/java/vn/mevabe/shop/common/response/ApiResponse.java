package vn.mevabe.shop.common.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

/**
 * Vo boc chuan cho MOI response tra ve client.
 * Nho vay frontend luon nhan cung 1 dinh dang, de xu ly.
 *
 * Vi du body:
 * {
 *   "success": true,
 *   "code": "OK",
 *   "message": "Thanh cong",
 *   "data": { ... },
 *   "timestamp": "2026-08-13T00:00:00Z"
 * }
 */
@Getter
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private final boolean success;
    private final String code;
    private final String message;
    private final T data;
    private final Object errors;

    @Builder.Default
    private final Instant timestamp = Instant.now();

    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .code("OK")
                .message("Thanh cong")
                .data(data)
                .build();
    }

    public static <T> ApiResponse<T> success(T data, String message) {
        return ApiResponse.<T>builder()
                .success(true)
                .code("OK")
                .message(message)
                .data(data)
                .build();
    }

    public static ApiResponse<Void> error(String code, String message, Object errors) {
        return ApiResponse.<Void>builder()
                .success(false)
                .code(code)
                .message(message)
                .errors(errors)
                .build();
    }
}
