package ${packageName}.integration.pulsar;

import org.junit.jupiter.api.Test;

class DemoPulsarConsumeListenerTest {

  @Test
  void shouldConsumeMessageWithoutException() {
    DemoPulsarConsumeListener listener = new DemoPulsarConsumeListener();
    listener.onMessage("hello");
  }
}
