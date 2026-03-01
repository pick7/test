package ${packageName}.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

@ExtendWith(MockitoExtension.class)
class DemoRedisValueServiceTest {

  @Mock
  private StringRedisTemplate redisTemplate;

  @Mock
  private ValueOperations<String, String> valueOperations;

  @InjectMocks
  private DemoRedisValueService redisValueService;

  @Test
  void shouldSetAndGetValue() {
    when(redisTemplate.opsForValue()).thenReturn(valueOperations);

    redisValueService.set("demo-key", "demo-value");
    verify(valueOperations).set("demo-key", "demo-value");

    when(valueOperations.get("demo-key")).thenReturn("demo-value");
    assertThat(redisValueService.get("demo-key")).contains("demo-value");
  }

  @Test
  void shouldReturnEmptyWhenValueMissing() {
    when(redisTemplate.opsForValue()).thenReturn(valueOperations);
    when(valueOperations.get("missing-key")).thenReturn(null);

    assertThat(redisValueService.get("missing-key")).isEmpty();
  }
}
