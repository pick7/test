package ${packageName}.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import ${packageName}.support.PostgresTestDataCleaner;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class DemoUserE2ETest extends PostgresTestDataCleaner {

  @Autowired
  private TestRestTemplate restTemplate;

  @Test
  @SuppressWarnings("unchecked")
  void shouldCreateAndGetUserByHttp() {
    ResponseEntity<Map> createResponse = restTemplate.postForEntity(
        "/api/demo/users",
        Map.of("username", "e2e-user", "email", "e2e-user@test.com"),
        Map.class);

    assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(createResponse.getBody()).isNotNull();
    Map<String, Object> createBody = createResponse.getBody();
    assertThat(createBody.get("code")).isEqualTo("0");

    Map<String, Object> createData = (Map<String, Object>) createBody.get("data");
    Integer userId = (Integer) createData.get("id");
    assertThat(userId).isNotNull();

    ResponseEntity<Map> getResponse = restTemplate.getForEntity(
        "/api/demo/users/" + userId,
        Map.class);

    assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(getResponse.getBody()).isNotNull();
    Map<String, Object> getBody = getResponse.getBody();
    assertThat(getBody.get("code")).isEqualTo("0");
  }
}
