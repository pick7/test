package ${packageName}.common.result;

import ${packageName}.common.enums.ErrorCode;

public record Result<T>(String code, String message, T data) {

  public static <T> Result<T> success(T data) {
    return new Result<>(ErrorCode.SUCCESS.code(), ErrorCode.SUCCESS.message(), data);
  }

  public static Result<Void> success() {
    return new Result<>(ErrorCode.SUCCESS.code(), ErrorCode.SUCCESS.message(), null);
  }

  public static <T> Result<T> fail(ErrorCode errorCode) {
    return new Result<>(errorCode.code(), errorCode.message(), null);
  }

  public static <T> Result<T> fail(String code, String message) {
    return new Result<>(code, message, null);
  }
}
