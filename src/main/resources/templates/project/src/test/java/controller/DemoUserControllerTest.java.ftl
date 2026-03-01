package ${packageName}.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ${packageName}.support.PostgresTestDataCleaner;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class DemoUserControllerTest extends PostgresTestDataCleaner {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private ObjectMapper objectMapper;

  @Test
  void shouldSupportCrudFlow() throws Exception {
    Long userId = createUser("alice", "alice@test.com");

    mockMvc.perform(get("/api/demo/users/{id}", userId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.data.username").value("alice"));

    mockMvc.perform(get("/api/demo/users"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"))
        .andExpect(jsonPath("$.data.length()", greaterThanOrEqualTo(1)));

    mockMvc.perform(
            put("/api/demo/users/{id}", userId)
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    objectMapper.writeValueAsString(
                        Map.of("username", "alice-updated", "email", "alice-updated@test.com"))))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.data.username").value("alice-updated"));

    mockMvc.perform(delete("/api/demo/users/{id}", userId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.code").value("0"));

    mockMvc.perform(get("/api/demo/users/{id}", userId))
        .andExpect(status().isNotFound())
        .andExpect(jsonPath("$.code").value("USER_NOT_FOUND"));
  }

  @Test
  void shouldReturnValidationErrorWhenRequestInvalid() throws Exception {
    mockMvc.perform(
            post("/api/demo/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(Map.of("username", "", "email", "invalid"))))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
  }

  @Test
  void shouldReturnConflictWhenEmailAlreadyExists() throws Exception {
    createUser("alice", "same@test.com");

    mockMvc.perform(
            post("/api/demo/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    objectMapper.writeValueAsString(
                        Map.of("username", "bob", "email", "same@test.com"))))
        .andExpect(status().isConflict())
        .andExpect(jsonPath("$.code").value("USER_EMAIL_ALREADY_EXISTS"));
  }

  @Test
  void shouldReturnConflictWhenUpdateEmailAlreadyExists() throws Exception {
    Long firstId = createUser("alice", "first@test.com");
    Long secondId = createUser("bob", "second@test.com");

    mockMvc.perform(
            put("/api/demo/users/{id}", secondId)
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    objectMapper.writeValueAsString(
                        Map.of("username", "bob-updated", "email", "first@test.com"))))
        .andExpect(status().isConflict())
        .andExpect(jsonPath("$.code").value("USER_EMAIL_ALREADY_EXISTS"));

    mockMvc.perform(get("/api/demo/users/{id}", firstId))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.data.email").value("first@test.com"));
  }

  private Long createUser(String username, String email) throws Exception {
    MvcResult result =
        mockMvc.perform(
                post("/api/demo/users")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(
                        objectMapper.writeValueAsString(
                            Map.of("username", username, "email", email))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value("0"))
            .andReturn();

    JsonNode root = objectMapper.readTree(result.getResponse().getContentAsString());
    Long id = root.path("data").path("id").asLong();
    assertThat(id).isNotNull();
    return id;
  }
}
