package ${packageName}.exception;

import ${packageName}.common.enums.ErrorCode;

public class BizException extends RuntimeException {

  private final ErrorCode errorCode;

  public BizException(ErrorCode errorCode) {
    super(errorCode.message());
    this.errorCode = errorCode;
  }

  public ErrorCode getErrorCode() {
    return errorCode;
  }
}
