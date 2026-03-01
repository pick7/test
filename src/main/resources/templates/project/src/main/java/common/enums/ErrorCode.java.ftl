package ${packageName}.common.enums;

public enum ErrorCode {
  SUCCESS("0", "success"),
  USER_NOT_FOUND("USER_NOT_FOUND", "User not found"),
  USER_EMAIL_ALREADY_EXISTS("USER_EMAIL_ALREADY_EXISTS", "Email already exists"),
  REDIS_KEY_NOT_FOUND("REDIS_KEY_NOT_FOUND", "Redis key not found"),
  PULSAR_PUBLISH_FAILED("PULSAR_PUBLISH_FAILED", "Failed to publish message to Pulsar"),
  VALIDATION_ERROR("VALIDATION_ERROR", "Validation failed"),
  INTERNAL_ERROR("INTERNAL_ERROR", "Internal server error");

  private final String code;
  private final String message;

  ErrorCode(String code, String message) {
    this.code = code;
    this.message = message;
  }

  public String code() {
    return code;
  }

  public String message() {
    return message;
  }
}
