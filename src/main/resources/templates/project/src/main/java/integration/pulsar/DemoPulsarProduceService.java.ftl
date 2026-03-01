package ${packageName}.integration.pulsar;

import ${packageName}.common.enums.ErrorCode;
import ${packageName}.exception.BizException;
import lombok.RequiredArgsConstructor;
import org.apache.pulsar.client.api.PulsarClientException;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.pulsar.core.PulsarTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "app.pulsar.producer", name = "enabled", havingValue = "true")
public class DemoPulsarProduceService {

  private final PulsarTemplate<String> pulsarTemplate;

  public void send(String topic, String message) {
    try {
      pulsarTemplate.send(topic, message);
    } catch (PulsarClientException ex) {
      throw new BizException(ErrorCode.PULSAR_PUBLISH_FAILED);
    }
  }
}
