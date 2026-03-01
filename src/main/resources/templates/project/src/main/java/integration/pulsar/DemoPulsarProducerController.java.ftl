package ${packageName}.integration.pulsar;

import ${packageName}.common.constant.AppConstants;
import ${packageName}.common.result.Result;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping(AppConstants.API_PREFIX + "/demo/pulsar/producer")
@ConditionalOnProperty(prefix = "app.pulsar.producer", name = "enabled", havingValue = "true")
/**
 * [SCAFFOLD DEMO] Pulsar 生产者示例接口。
 *
 * <p>用于演示可选组件开启后的最小消息发送流程。
 */
public class DemoPulsarProducerController {

  private final DemoPulsarProduceService producerService;

  @PostMapping("/send")
  public ResponseEntity<Result<Map<String, String>>> send(@Valid @RequestBody SendRequest request) {
    producerService.send(request.topic(), request.message());
    return ResponseEntity.accepted()
        .body(Result.success(Map.of("status", "SENT", "topic", request.topic())));
  }

  public record SendRequest(
      @NotBlank(message = "topic cannot be blank") String topic,
      @NotBlank(message = "message cannot be blank") String message) {
  }
}
