package ${packageName}.service.impl;

import ${packageName}.common.enums.ErrorCode;
import ${packageName}.dto.request.DemoUserCreateRequest;
import ${packageName}.dto.request.DemoUserUpdateRequest;
import ${packageName}.dto.response.DemoUserResponse;
import ${packageName}.entity.DemoUserEntity;
import ${packageName}.exception.BizException;
import ${packageName}.repository.DemoUserRepository;
import ${packageName}.service.DemoUserService;
import ${packageName}.util.DemoUserMapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DemoUserServiceImpl implements DemoUserService {

  private final DemoUserRepository userRepository;

  @Override
  @Transactional
  public DemoUserResponse create(DemoUserCreateRequest request) {
    if (userRepository.existsByEmail(request.email())) {
      throw new BizException(ErrorCode.USER_EMAIL_ALREADY_EXISTS);
    }

    DemoUserEntity userEntity =
        DemoUserEntity.builder().username(request.username()).email(request.email()).build();
    return DemoUserMapper.toResponse(userRepository.save(userEntity));
  }

  @Override
  public DemoUserResponse getById(Long id) {
    return DemoUserMapper.toResponse(getEntityById(id));
  }

  @Override
  public List<DemoUserResponse> list() {
    return userRepository.findAll(Sort.by(Sort.Direction.ASC, "id")).stream()
        .map(DemoUserMapper::toResponse)
        .toList();
  }

  @Override
  @Transactional
  public DemoUserResponse update(Long id, DemoUserUpdateRequest request) {
    DemoUserEntity userEntity = getEntityById(id);
    if (userRepository.existsByEmailAndIdNot(request.email(), id)) {
      throw new BizException(ErrorCode.USER_EMAIL_ALREADY_EXISTS);
    }

    userEntity.setUsername(request.username());
    userEntity.setEmail(request.email());
    return DemoUserMapper.toResponse(userRepository.save(userEntity));
  }

  @Override
  @Transactional
  public void delete(Long id) {
    userRepository.delete(getEntityById(id));
  }

  private DemoUserEntity getEntityById(Long id) {
    return userRepository.findById(id).orElseThrow(() -> new BizException(ErrorCode.USER_NOT_FOUND));
  }
}
