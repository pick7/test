package ${packageName}.service;

import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "app.redis", name = "enabled", havingValue = "true")
/**
 * Redis KV 操作服务。
 *
 * <p>封装最小可用的字符串读写能力，便于控制层复用并在后续按需扩展为 Hash/List 等结构。
 */
public class DemoRedisValueService {

  private final StringRedisTemplate redisTemplate;

  /** 写入字符串值。 */
  public void set(String key, String value) {
    redisTemplate.opsForValue().set(key, value);
  }

  /** 读取字符串值，未命中时返回空 Optional。 */
  public Optional<String> get(String key) {
    return Optional.ofNullable(redisTemplate.opsForValue().get(key));
  }
}
