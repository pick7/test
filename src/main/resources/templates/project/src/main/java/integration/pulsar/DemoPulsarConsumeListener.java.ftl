package ${packageName}.integration.pulsar;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.pulsar.annotation.PulsarListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@ConditionalOnProperty(prefix = "app.pulsar.consumer", name = "enabled", havingValue = "true")
public class DemoPulsarConsumeListener {

  @PulsarListener(
      topics = "<#noparse>${app.pulsar.consumer.topic:demo-topic}</#noparse>",
      subscriptionName = "<#noparse>${app.pulsar.consumer.subscription:demo-subscription}</#noparse>")
  public void onMessage(String payload) {
    log.info("Received Pulsar message: {}", payload);
  }
}
