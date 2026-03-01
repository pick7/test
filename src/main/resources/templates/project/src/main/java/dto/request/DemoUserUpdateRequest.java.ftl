package ${packageName}.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record DemoUserUpdateRequest(
    @NotBlank(message = "username cannot be blank") String username,
    @NotBlank(message = "email cannot be blank")
    @Email(message = "email format is invalid") String email) {
}
