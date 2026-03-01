package ${packageName}.exception;

import static org.assertj.core.api.Assertions.assertThat;

import ${packageName}.common.enums.ErrorCode;
import ${packageName}.common.result.Result;
import ${packageName}.dto.request.DemoUserCreateRequest;
import java.lang.reflect.Method;
import org.junit.jupiter.api.Test;
import org.springframework.core.MethodParameter;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.http.converter.HttpMessageNotReadableException;

class GlobalExceptionHandlerTest {

  private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

  @Test
  void shouldMapNotFoundBizExceptionTo404() {
    ResponseEntity<Result<Void>> response =
        handler.handleBizException(new BizException(ErrorCode.USER_NOT_FOUND));

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.USER_NOT_FOUND.code());
  }

  @Test
  void shouldMapConflictBizExceptionTo409() {
    ResponseEntity<Result<Void>> response =
        handler.handleBizException(new BizException(ErrorCode.USER_EMAIL_ALREADY_EXISTS));

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.USER_EMAIL_ALREADY_EXISTS.code());
  }

  @Test
  void shouldMapPulsarPublishFailureTo502() {
    ResponseEntity<Result<Void>> response =
        handler.handleBizException(new BizException(ErrorCode.PULSAR_PUBLISH_FAILED));

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_GATEWAY);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.PULSAR_PUBLISH_FAILED.code());
  }

  @Test
  void shouldMapDefaultBizExceptionTo400() {
    ResponseEntity<Result<Void>> response =
        handler.handleBizException(new BizException(ErrorCode.VALIDATION_ERROR));

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.VALIDATION_ERROR.code());
  }

  @Test
  void shouldHandleValidationException() throws Exception {
    Method method = getClass().getDeclaredMethod("validationTarget", DemoUserCreateRequest.class);
    MethodParameter methodParameter = new MethodParameter(method, 0);
    BeanPropertyBindingResult bindingResult = new BeanPropertyBindingResult(new Object(), "request");
    bindingResult.addError(new FieldError("request", "username", "username cannot be blank"));

    MethodArgumentNotValidException exception =
        new MethodArgumentNotValidException(methodParameter, bindingResult);

    ResponseEntity<Result<Void>> response = handler.handleValidationException(exception);

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.VALIDATION_ERROR.code());
    assertThat(response.getBody().message()).isEqualTo("username cannot be blank");
  }

  @Test
  void shouldHandleValidationExceptionWithoutFieldError() throws Exception {
    Method method = getClass().getDeclaredMethod("validationTarget", DemoUserCreateRequest.class);
    MethodParameter methodParameter = new MethodParameter(method, 0);
    BeanPropertyBindingResult bindingResult = new BeanPropertyBindingResult(new Object(), "request");

    MethodArgumentNotValidException exception =
        new MethodArgumentNotValidException(methodParameter, bindingResult);

    ResponseEntity<Result<Void>> response = handler.handleValidationException(exception);

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().message()).isEqualTo(ErrorCode.VALIDATION_ERROR.message());
  }

  @Test
  void shouldHandleDataIntegrityException() {
    ResponseEntity<Result<Void>> response =
        handler.handleDataIntegrityException(new DataIntegrityViolationException("duplicate"));

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.USER_EMAIL_ALREADY_EXISTS.code());
  }

  @Test
  void shouldHandleBadRequestBodyException() {
    ResponseEntity<Result<Void>> response =
        handler.handleBadRequestException(new HttpMessageNotReadableException("missing body"));

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.VALIDATION_ERROR.code());
  }

  @Test
  void shouldHandleMissingRequestParameterException() {
    ResponseEntity<Result<Void>> response =
        handler.handleBadRequestException(
            new MissingServletRequestParameterException("topic", "String"));

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.VALIDATION_ERROR.code());
  }

  @Test
  void shouldHandleUnknownException() {
    ResponseEntity<Result<Void>> response = handler.handleException(new RuntimeException("boom"));

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.INTERNAL_ERROR.code());
  }

  @SuppressWarnings("unused")
  private void validationTarget(DemoUserCreateRequest request) {
  }
}
