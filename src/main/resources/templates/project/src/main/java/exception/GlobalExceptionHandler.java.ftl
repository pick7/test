package ${packageName}.exception;

import ${packageName}.common.enums.ErrorCode;
import ${packageName}.common.result.Result;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

  @ExceptionHandler(BizException.class)
  public ResponseEntity<Result<Void>> handleBizException(BizException ex) {
    ErrorCode errorCode = ex.getErrorCode();
    return ResponseEntity.status(resolveStatus(errorCode)).body(Result.fail(errorCode));
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<Result<Void>> handleValidationException(MethodArgumentNotValidException ex) {
    FieldError fieldError = ex.getBindingResult().getFieldError();
    String message = fieldError == null ? ErrorCode.VALIDATION_ERROR.message() : fieldError.getDefaultMessage();
    return ResponseEntity.badRequest().body(Result.fail(ErrorCode.VALIDATION_ERROR.code(), message));
  }

  @ExceptionHandler(DataIntegrityViolationException.class)
  public ResponseEntity<Result<Void>> handleDataIntegrityException(DataIntegrityViolationException ex) {
    return ResponseEntity.status(HttpStatus.CONFLICT)
        .body(Result.fail(ErrorCode.USER_EMAIL_ALREADY_EXISTS));
  }

  @ExceptionHandler({HttpMessageNotReadableException.class, MissingServletRequestParameterException.class})
  public ResponseEntity<Result<Void>> handleBadRequestException(Exception ex) {
    return ResponseEntity.badRequest().body(Result.fail(ErrorCode.VALIDATION_ERROR));
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<Result<Void>> handleException(Exception ex) {
    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
        .body(Result.fail(ErrorCode.INTERNAL_ERROR));
  }

  private HttpStatus resolveStatus(ErrorCode errorCode) {
    return switch (errorCode) {
      case USER_NOT_FOUND, REDIS_KEY_NOT_FOUND -> HttpStatus.NOT_FOUND;
      case USER_EMAIL_ALREADY_EXISTS -> HttpStatus.CONFLICT;
      case PULSAR_PUBLISH_FAILED -> HttpStatus.BAD_GATEWAY;
      default -> HttpStatus.BAD_REQUEST;
    };
  }
}
