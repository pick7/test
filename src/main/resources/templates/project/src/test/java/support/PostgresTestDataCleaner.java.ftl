package ${packageName}.support;

import java.util.List;
import java.util.stream.Collectors;
import org.junit.jupiter.api.AfterEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * 测试数据清理基类。
 *
 * <p>所有需要访问真实 PostgreSQL 的集成测试可继承该类，在每个测试方法执行后自动清空数据。
 */
public abstract class PostgresTestDataCleaner {

  @Autowired
  private JdbcTemplate jdbcTemplate;

  @AfterEach
  void cleanupDatabase() {
    List<String> tables =
        jdbcTemplate.queryForList(
            """
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = 'public'
              AND tablename <> 'flyway_schema_history'
            """,
            String.class);
    if (tables.isEmpty()) {
      return;
    }

    String joinedTables =
        tables.stream().map(table -> "\"" + table + "\"").collect(Collectors.joining(", "));
    jdbcTemplate.execute("TRUNCATE TABLE " + joinedTables + " RESTART IDENTITY CASCADE");
  }
}
