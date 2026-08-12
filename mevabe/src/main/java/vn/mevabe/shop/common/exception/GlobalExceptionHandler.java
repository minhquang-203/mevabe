package vn.mevabe.shop.common.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import vn.mevabe.shop.common.response.ApiResponse;

import java.util.HashMap;
import java.util.Map;

/**
 * Bat MOI exception o 1 noi duy nhat va tra ve ApiResponse thong nhat.
 * Controller khong can try/catch -> code sach hon.
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(AppException.class)
    public ResponseEntity<ApiResponse<Void>> handleApp(AppException ex) {
        ErrorCode ec = ex.getErrorCode();
        return ResponseEntity
                .status(ec.getStatus())
                .body(ApiResponse.error(ec.getCode(), ex.getMessage(), null));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> fieldErrors = new HashMap<>();
        for (FieldError fe : ex.getBindingResult().getFieldErrors()) {
            fieldErrors.put(fe.getField(), fe.getDefaultMessage());
        }
        ErrorCode ec = ErrorCode.VALIDATION_ERROR;
        return ResponseEntity
                .status(ec.getStatus())
                .body(ApiResponse.error(ec.getCode(), ec.getMessage(), fieldErrors));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleUnknown(Exception ex) {
        log.error("Loi khong luong truoc", ex);
        ErrorCode ec = ErrorCode.INTERNAL_ERROR;
        return ResponseEntity
                .status(ec.getStatus())
                .body(ApiResponse.error(ec.getCode(), ec.getMessage(), null));
    }
}
