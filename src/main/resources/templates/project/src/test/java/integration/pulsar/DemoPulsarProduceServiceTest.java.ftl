package ${packageName}.integration.pulsar;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.catchThrowableOfType;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;

import ${packageName}.common.enums.ErrorCode;
import ${packageName}.exception.BizException;
import org.apache.pulsar.client.api.PulsarClientException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.pulsar.core.PulsarTemplate;

@ExtendWith(MockitoExtension.class)
class DemoPulsarProduceServiceTest {

  @Mock
  private PulsarTemplate<String> pulsarTemplate;

  @InjectMocks
  private DemoPulsarProduceService pulsarProduceService;

  @Test
  void shouldSendMessage() throws PulsarClientException {
    pulsarProduceService.send("demo-topic", "hello");
    verify(pulsarTemplate).send("demo-topic", "hello");
  }

  @Test
  void shouldThrowBizExceptionWhenPublishFails() throws PulsarClientException {
    doThrow(new PulsarClientException("publish failed"))
        .when(pulsarTemplate)
        .send("demo-topic", "hello");

    BizException exception =
        catchThrowableOfType(() -> pulsarProduceService.send("demo-topic", "hello"), BizException.class);

    assertThat(exception).isNotNull();
    assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.PULSAR_PUBLISH_FAILED);
  }
}
