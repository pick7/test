package ${packageName};

import ${packageName}.support.PostgresTestDataCleaner;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class ${appClass}Tests extends PostgresTestDataCleaner {

  @Test
  void contextLoads() {
  }
}
