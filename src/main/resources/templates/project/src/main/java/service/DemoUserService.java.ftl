package ${packageName}.service;

import ${packageName}.dto.request.DemoUserCreateRequest;
import ${packageName}.dto.request.DemoUserUpdateRequest;
import ${packageName}.dto.response.DemoUserResponse;
import java.util.List;

public interface DemoUserService {

  DemoUserResponse create(DemoUserCreateRequest request);

  DemoUserResponse getById(Long id);

  List<DemoUserResponse> list();

  DemoUserResponse update(Long id, DemoUserUpdateRequest request);

  void delete(Long id);
}
