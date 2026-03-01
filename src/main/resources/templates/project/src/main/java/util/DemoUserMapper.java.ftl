package ${packageName}.util;

import ${packageName}.dto.response.DemoUserResponse;
import ${packageName}.entity.DemoUserEntity;
import ${packageName}.vo.DemoUserVO;

public final class DemoUserMapper {

  private DemoUserMapper() {
  }

  public static DemoUserResponse toResponse(DemoUserEntity entity) {
    return new DemoUserResponse(entity.getId(), entity.getUsername(), entity.getEmail());
  }

  public static DemoUserVO toVo(DemoUserEntity entity) {
    return new DemoUserVO(entity.getId(), entity.getUsername(), entity.getEmail());
  }
}
