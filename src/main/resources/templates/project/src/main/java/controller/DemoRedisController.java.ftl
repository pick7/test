package ${packageName}.controller;

import ${packageName}.common.constant.AppConstants;
import ${packageName}.common.enums.ErrorCode;
import ${packageName}.common.result.Result;
import ${packageName}.service.DemoRedisValueService;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping(AppConstants.API_PREFIX + "/demo/redis")
@ConditionalOnProperty(prefix = "app.redis", name = "enabled", havingValue = "true")
/**
 * [SCAFFOLD DEMO] Redis 示例接口。
 *
 * <p>仅在 `app.redis.enabled=true` 时加载，提供最小可用的写入/读取演示接口。
 */
public class DemoRedisController {

  private final DemoRedisValueService redisValueService;

  /** 写入键值对。 */
  @PostMapping("/values/{key}")
  public ResponseEntity<Result<Map<String, String>>> setValue(
      @PathVariable String key,
      @RequestBody String value) {
    redisValueService.set(key, value);
    return ResponseEntity.ok(Result.success(Map.of("key", key, "value", value)));
  }

  /** 读取键值对，未命中时返回 404 业务错误码。 */
  @GetMapping("/values/{key}")
  public ResponseEntity<Result<Map<String, String>>> getValue(@PathVariable String key) {
    return redisValueService.get(key)
        .map(value -> ResponseEntity.ok(Result.success(Map.of("key", key, "value", value))))
        .orElseGet(
            () ->
                ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Result.fail(ErrorCode.REDIS_KEY_NOT_FOUND)));
  }
}
