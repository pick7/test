package ${packageName}.controller;

import ${packageName}.annotation.OperationLog;
import ${packageName}.common.constant.AppConstants;
import ${packageName}.common.result.Result;
import ${packageName}.dto.request.DemoUserCreateRequest;
import ${packageName}.dto.request.DemoUserUpdateRequest;
import ${packageName}.dto.response.DemoUserResponse;
import ${packageName}.service.DemoUserService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping(AppConstants.API_PREFIX + "/demo/users")
/**
 * [SCAFFOLD DEMO] 用户示例接口。
 *
 * <p>该类用于演示标准 CRUD 分层写法，业务落地时可直接替换为真实领域接口。
 */
public class DemoUserController {

  private final DemoUserService userService;

  @PostMapping
  @OperationLog("create-demo-user")
  public Result<DemoUserResponse> create(@Valid @RequestBody DemoUserCreateRequest request) {
    return Result.success(userService.create(request));
  }

  @GetMapping("/{id}")
  @OperationLog("get-demo-user")
  public Result<DemoUserResponse> getById(@PathVariable Long id) {
    return Result.success(userService.getById(id));
  }

  @GetMapping
  @OperationLog("list-demo-users")
  public Result<List<DemoUserResponse>> list() {
    return Result.success(userService.list());
  }

  @PutMapping("/{id}")
  @OperationLog("update-demo-user")
  public Result<DemoUserResponse> update(
      @PathVariable Long id,
      @Valid @RequestBody DemoUserUpdateRequest request) {
    return Result.success(userService.update(id, request));
  }

  @DeleteMapping("/{id}")
  @OperationLog("delete-demo-user")
  public Result<Void> delete(@PathVariable Long id) {
    userService.delete(id);
    return Result.success();
  }
}
