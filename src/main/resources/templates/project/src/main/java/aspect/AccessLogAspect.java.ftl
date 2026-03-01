package ${packageName}.aspect;

import ${packageName}.annotation.OperationLog;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

@Slf4j
@Aspect
@Component
public class AccessLogAspect {

  @Around("@annotation(operationLog)")
  public Object around(ProceedingJoinPoint joinPoint, OperationLog operationLog) throws Throwable {
    long start = System.currentTimeMillis();
    try {
      return joinPoint.proceed();
    } finally {
      long cost = System.currentTimeMillis() - start;
      log.info("{} finished in {} ms", operationLog.value(), cost);
    }
  }
}
