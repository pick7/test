package ${packageName}.integration.pulsar;

import static org.assertj.core.api.Assertions.assertThat;

import ${packageName}.common.result.Result;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

class DemoPulsarProducerControllerTest {

  @Test
  void shouldSendMessage() {
    StubPulsarProduceService service = new StubPulsarProduceService();
    DemoPulsarProducerController controller = new DemoPulsarProducerController(service);

    DemoPulsarProducerController.SendRequest request =
        new DemoPulsarProducerController.SendRequest("demo-topic", "hello");

    ResponseEntity<Result<Map<String, String>>> response = controller.send(request);

    assertThat(service.lastTopic).isEqualTo("demo-topic");
    assertThat(service.lastMessage).isEqualTo("hello");
    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.ACCEPTED);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().code()).isEqualTo("0");
    assertThat(response.getBody().data().get("status")).isEqualTo("SENT");
  }

  private static class StubPulsarProduceService extends DemoPulsarProduceService {

    private String lastTopic;
    private String lastMessage;

    StubPulsarProduceService() {
      super(null);
    }

    @Override
    public void send(String topic, String message) {
      this.lastTopic = topic;
      this.lastMessage = message;
    }
  }
}
