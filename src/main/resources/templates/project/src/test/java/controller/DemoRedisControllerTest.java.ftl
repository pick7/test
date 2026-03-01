package ${packageName}.controller;

import static org.assertj.core.api.Assertions.assertThat;

import ${packageName}.common.enums.ErrorCode;
import ${packageName}.common.result.Result;
import ${packageName}.service.DemoRedisValueService;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

class DemoRedisControllerTest {

  @Test
  void shouldSetAndGetValue() {
    StubRedisValueService service = new StubRedisValueService();
    DemoRedisController controller = new DemoRedisController(service);

    ResponseEntity<Result<Map<String, String>>> setResponse =
        controller.setValue("demo-key", "demo-value");
    ResponseEntity<Result<Map<String, String>>> getResponse = controller.getValue("demo-key");

    assertThat(setResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(setResponse.getBody()).isNotNull();
    assertThat(setResponse.getBody().code()).isEqualTo("0");
    assertThat(setResponse.getBody().data().get("value")).isEqualTo("demo-value");

    assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(getResponse.getBody()).isNotNull();
    assertThat(getResponse.getBody().code()).isEqualTo("0");
    assertThat(getResponse.getBody().data().get("key")).isEqualTo("demo-key");
  }

  @Test
  void shouldReturnNotFoundWhenKeyMissing() {
    DemoRedisController controller = new DemoRedisController(new StubRedisValueService());

    ResponseEntity<Result<Map<String, String>>> response = controller.getValue("missing-key");

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo(ErrorCode.REDIS_KEY_NOT_FOUND.code());
  }

  private static class StubRedisValueService extends DemoRedisValueService {

    private final Map<String, String> store = new HashMap<>();

    StubRedisValueService() {
      super(null);
    }

    @Override
    public void set(String key, String value) {
      store.put(key, value);
    }

    @Override
    public Optional<String> get(String key) {
      return Optional.ofNullable(store.get(key));
    }
  }
}
