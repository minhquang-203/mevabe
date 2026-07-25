package org.example.mevabe.shared.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.Map;

/**
 * Envelope phản hồi API thống nhất cho toàn bộ hệ thống.
 *
 * <pre>
 * Thành công: { status, message, data, timestamp }
 * Thất bại:   { status, code, message, errors?, timestamp }
 * </pre>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_FAILED = "FAILED";

    private String status;
    private String code;
    private String message;
    private T data;
    private Map<String, String> errors;
    private Instant timestamp;

    public static <T> ApiResponse<T> success(T data) {
        return success(null, data);
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return ApiResponse.<T>builder()
                .status(STATUS_SUCCESS)
                .message(message)
                .data(data)
                .timestamp(Instant.now())
                .build();
    }

    public static <T> ApiResponse<T> successMessage(String message) {
        return success(message, null);
    }

    public static <T> ApiResponse<T> fail(String code, String message) {
        return fail(code, message, null);
    }

    public static <T> ApiResponse<T> fail(String code, String message, Map<String, String> errors) {
        return ApiResponse.<T>builder()
                .status(STATUS_FAILED)
                .code(code)
                .message(message)
                .errors(errors)
                .timestamp(Instant.now())
                .build();
    }
}
