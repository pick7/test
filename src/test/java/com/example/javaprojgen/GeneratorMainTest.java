package com.example.javaprojgen;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import picocli.CommandLine;

class GeneratorMainTest {

  @TempDir
  Path tempDir;

  @Test
  void shouldSupportHelpOption() {
    int longHelpExitCode = execute("--help");
    int shortHelpExitCode = execute("-h");

    assertThat(longHelpExitCode).isEqualTo(0);
    assertThat(shortHelpExitCode).isEqualTo(0);
  }

  @Test
  void shouldGenerateProjectWithCoreFiles() throws IOException {
    int exitCode =
        execute(
            "--project-name",
            "demo-core",
            "--group-id",
            "com.acme",
            "--artifact-id",
            "demo-core",
            "--package-name",
            "com.acme.democore",
            "--output",
            tempDir.toString());

    assertThat(exitCode).isEqualTo(0);

    Path projectRoot = tempDir.resolve("demo-core");
    assertThat(projectRoot.resolve("pom.xml")).exists();
    assertThat(projectRoot.resolve(".mvn/jvm.config")).exists();
    assertThat(projectRoot.resolve("src/main/resources/application.yml")).exists();
    assertThat(projectRoot.resolve("src/main/resources/application-test.yml")).exists();
    assertThat(projectRoot.resolve("src/main/resources/db/migration/V1__create_demo_users_table.sql"))
        .exists();
    assertThat(projectRoot.resolve("src/main/java/com/acme/democore/entity/BaseEntity.java")).exists();
    assertThat(projectRoot.resolve("src/main/java/com/acme/democore/proxy/DemoExampleProxy.java")).exists();
    assertThat(projectRoot.resolve("src/main/java/com/acme/democore/controller/DemoUserController.java")).exists();
    assertThat(projectRoot.resolve("src/test/java/com/acme/democore/e2e/DemoUserE2ETest.java")).exists();
    assertThat(projectRoot.resolve("src/test/java/com/acme/democore/arch/ArchitectureRuleTest.java"))
        .exists();
    assertThat(projectRoot.resolve("src/test/java/com/acme/democore/support/PostgresTestDataCleaner.java"))
        .exists();

    String applicationYml =
        Files.readString(projectRoot.resolve("src/main/resources/application.yml"), StandardCharsets.UTF_8);
    assertThat(applicationYml).contains("SPRING_DATASOURCE_URL");
    assertThat(applicationYml).contains("postgresql://localhost:5432/postgres");
    assertThat(applicationYml).contains("ddl-auto: validate");
    assertThat(applicationYml).contains("flyway:");

    String applicationTestYml =
        Files.readString(projectRoot.resolve("src/main/resources/application-test.yml"), StandardCharsets.UTF_8);
    assertThat(applicationTestYml).contains("TEST_DB_URL");
    assertThat(applicationTestYml).contains("postgresql://localhost:5432/postgres_test");
    assertThat(applicationTestYml).contains("ddl-auto: validate");

    String pom = Files.readString(projectRoot.resolve("pom.xml"), StandardCharsets.UTF_8);
    assertThat(pom).contains("maven-pmd-plugin");
    assertThat(pom).contains("p3c-pmd");
    assertThat(pom).contains("archunit-junit5");
    assertThat(pom).contains("flyway-core");
    assertThat(pom).doesNotContain("<artifactId>h2</artifactId>");
    assertThat(pom).contains("<p3c.failOnViolation>true</p3c.failOnViolation>");
    assertThat(pom).contains("<p3c.skip>false</p3c.skip>");
    assertThat(pom).contains("<id>p3c-advisory</id>");
    assertThat(pom).contains("<id>p3c-strict</id>");
    assertThat(pom).contains("<id>p3c-off</id>");

    String jvmConfig = Files.readString(projectRoot.resolve(".mvn/jvm.config"), StandardCharsets.UTF_8);
    assertThat(jvmConfig).contains("com.sun.tools.javac.comp");

    assertThat(projectRoot.resolve("src/main/java/com/acme/democore/integration")).doesNotExist();
  }

  @Test
  void shouldGenerateOptionalModulesAndTheirTests() throws IOException {
    int exitCode =
        execute(
            "--project-name",
            "demo-modules",
            "--group-id",
            "com.acme",
            "--artifact-id",
            "demo-modules",
            "--package-name",
            "com.acme.demomodules",
            "--modules",
            "redis,pulsar-producer,pulsar-consumer",
            "--output",
            tempDir.toString());

    assertThat(exitCode).isEqualTo(0);

    Path projectRoot = tempDir.resolve("demo-modules");
    assertThat(projectRoot.resolve("src/main/java/com/acme/demomodules/controller/DemoRedisController.java"))
        .exists();
    assertThat(projectRoot.resolve("src/main/java/com/acme/demomodules/service/DemoRedisValueService.java"))
        .exists();
    assertThat(
            projectRoot.resolve(
                "src/main/java/com/acme/demomodules/integration/pulsar/DemoPulsarProducerController.java"))
        .exists();
    assertThat(
            projectRoot.resolve(
                "src/main/java/com/acme/demomodules/integration/pulsar/DemoPulsarConsumeListener.java"))
        .exists();

    assertThat(
            projectRoot.resolve("src/test/java/com/acme/demomodules/controller/DemoRedisControllerTest.java"))
        .exists();
    assertThat(
            projectRoot.resolve("src/test/java/com/acme/demomodules/service/DemoRedisValueServiceTest.java"))
        .exists();
    assertThat(
            projectRoot.resolve(
                "src/test/java/com/acme/demomodules/integration/pulsar/DemoPulsarProducerControllerTest.java"))
        .exists();

    String pom = Files.readString(projectRoot.resolve("pom.xml"), StandardCharsets.UTF_8);
    assertThat(pom).contains("spring-boot-starter-data-redis");
    assertThat(pom).contains("spring-boot-starter-pulsar");

    String gitignore = Files.readString(projectRoot.resolve(".gitignore"), StandardCharsets.UTF_8);
    assertThat(gitignore).contains("*.log");
  }

  @Test
  void shouldRejectUnsupportedModule() {
    int exitCode =
        execute(
            "--project-name",
            "demo-invalid-module",
            "--group-id",
            "com.acme",
            "--artifact-id",
            "demo-invalid-module",
            "--package-name",
            "com.acme.demoinvalidmodule",
            "--modules",
            "unknown",
            "--output",
            tempDir.toString());

    assertThat(exitCode).isEqualTo(2);
  }

  @Test
  void shouldValidateBootLine() {
    int mismatchExitCode =
        execute(
            "--project-name",
            "demo-boot-line-mismatch",
            "--group-id",
            "com.acme",
            "--artifact-id",
            "demo-boot-line-mismatch",
            "--package-name",
            "com.acme.demobootlinemismatch",
            "--boot-version",
            "3.3.1",
            "--boot-line",
            "3.2",
            "--output",
            tempDir.toString());

    assertThat(mismatchExitCode).isEqualTo(2);

    int skipLineCheckExitCode =
        execute(
            "--project-name",
            "demo-boot-line-skip",
            "--group-id",
            "com.acme",
            "--artifact-id",
            "demo-boot-line-skip",
            "--package-name",
            "com.acme.demobootlineskip",
            "--boot-version",
            "3.3.1",
            "--boot-line",
            "*",
            "--output",
            tempDir.toString());

    assertThat(skipLineCheckExitCode).isEqualTo(0);
  }

  @Test
  void shouldSupportP3cModeSwitch() throws IOException {
    int advisoryExitCode =
        execute(
            "--project-name",
            "demo-p3c-advisory",
            "--group-id",
            "com.acme",
            "--artifact-id",
            "demo-p3c-advisory",
            "--package-name",
            "com.acme.demop3cadvisory",
            "--p3c-mode",
            "advisory",
            "--output",
            tempDir.toString());

    assertThat(advisoryExitCode).isEqualTo(0);
    String advisoryPom =
        Files.readString(tempDir.resolve("demo-p3c-advisory/pom.xml"), StandardCharsets.UTF_8);
    assertThat(advisoryPom).contains("<p3c.failOnViolation>false</p3c.failOnViolation>");
    assertThat(advisoryPom).contains("<p3c.skip>false</p3c.skip>");

    int offExitCode =
        execute(
            "--project-name",
            "demo-p3c-off",
            "--group-id",
            "com.acme",
            "--artifact-id",
            "demo-p3c-off",
            "--package-name",
            "com.acme.demop3coff",
            "--p3c-mode",
            "off",
            "--output",
            tempDir.toString());

    assertThat(offExitCode).isEqualTo(0);
    String offPom = Files.readString(tempDir.resolve("demo-p3c-off/pom.xml"), StandardCharsets.UTF_8);
    assertThat(offPom).contains("<p3c.failOnViolation>false</p3c.failOnViolation>");
    assertThat(offPom).contains("<p3c.skip>true</p3c.skip>");
  }

  @Test
  void shouldRejectUnsupportedP3cMode() {
    int exitCode =
        execute(
            "--project-name",
            "demo-invalid-p3c-mode",
            "--group-id",
            "com.acme",
            "--artifact-id",
            "demo-invalid-p3c-mode",
            "--package-name",
            "com.acme.demoinvalidp3cmode",
            "--p3c-mode",
            "invalid",
            "--output",
            tempDir.toString());

    assertThat(exitCode).isEqualTo(2);
  }

  private int execute(String... args) {
    return new CommandLine(new GeneratorMain()).execute(args);
  }
}
