package com.example.javaprojgen;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;
import java.io.IOException;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

/**
 * 项目生成执行器。
 *
 * <p>职责聚焦在“把结构化配置转换成磁盘文件”：
 *
 * <p>1) 处理目标目录（覆盖、清空、创建）；
 *
 * <p>2) 构建模板模型（Freemarker 变量）；
 *
 * <p>3) 按固定顺序渲染基础模板、核心源码模板、可选模块模板。
 */
final class ProjectGenerator {

  private static final String MAIN_JAVA_TEMPLATE_ROOT = "project/src/main/java/";
  private static final String TEST_JAVA_TEMPLATE_ROOT = "project/src/test/java/";
  private static final List<ProjectTemplateTarget> PROJECT_TEMPLATE_TARGETS =
      List.of(
          new ProjectTemplateTarget("project/pom.xml.ftl", "pom.xml"),
          new ProjectTemplateTarget("project/README.md.ftl", "README.md"),
          new ProjectTemplateTarget("project/.gitignore.ftl", ".gitignore"),
          new ProjectTemplateTarget("project/.mvn/jvm.config.ftl", ".mvn/jvm.config"),
          new ProjectTemplateTarget(
              "project/src/main/resources/application.yml.ftl", "src/main/resources/application.yml"),
          new ProjectTemplateTarget(
              "project/src/main/resources/application-test.yml.ftl",
              "src/main/resources/application-test.yml"),
          new ProjectTemplateTarget(
              "project/src/main/resources/db/migration/V1__create_demo_users_table.sql.ftl",
              "src/main/resources/db/migration/V1__create_demo_users_table.sql"));
  private static final List<String> CORE_MAIN_TEMPLATE_FILES =
      List.of(
          "config/AppConfig.java",
          "controller/DemoUserController.java",
          "service/DemoUserService.java",
          "service/impl/DemoUserServiceImpl.java",
          "repository/DemoUserRepository.java",
          "entity/BaseEntity.java",
          "entity/DemoUserEntity.java",
          "dto/request/DemoUserCreateRequest.java",
          "dto/request/DemoUserUpdateRequest.java",
          "dto/response/DemoUserResponse.java",
          "vo/DemoUserVO.java",
          "exception/BizException.java",
          "exception/GlobalExceptionHandler.java",
          "common/result/Result.java",
          "common/constant/AppConstants.java",
          "common/enums/ErrorCode.java",
          "util/DemoUserMapper.java",
          "proxy/DemoExampleProxy.java",
          "aspect/AccessLogAspect.java",
          "annotation/OperationLog.java");
  private static final List<String> CORE_TEST_TEMPLATE_FILES =
      List.of(
          "arch/ArchitectureRuleTest.java",
          "controller/DemoUserControllerTest.java",
          "e2e/DemoUserE2ETest.java",
          "exception/GlobalExceptionHandlerTest.java",
          "support/PostgresTestDataCleaner.java");

  private final Map<String, ModuleDefinition> moduleRegistry;

  /**
   * @param moduleRegistry 可选模块注册表，包含模块 ID、模板清单及模板变量映射键
   */
  ProjectGenerator(Map<String, ModuleDefinition> moduleRegistry) {
    this.moduleRegistry = Map.copyOf(moduleRegistry);
  }

  /**
   * 生成项目主流程。
   *
   * <p>执行顺序固定，避免新增功能时破坏已有文件输出顺序：
   *
   * <p>目录准备 -> 上下文构建 -> 模板渲染（项目级、核心源码、模块源码）。
   */
  Path generate(ProjectConfig config) throws IOException, TemplateException {
    Path projectRoot = prepareProjectRoot(config);
    GenerationContext context = buildGenerationContext(config, projectRoot);
    Configuration configuration = createFreemarkerConfig();

    renderProjectTemplates(configuration, context);
    renderCoreSourceTemplates(configuration, context);
    renderModuleTemplates(configuration, context);
    return projectRoot;
  }

  /**
   * 准备项目根目录。
   *
   * <p>行为规则：
   *
   * <p>- 目标不存在：直接创建；
   *
   * <p>- 目标存在且为空目录：删除后重建（保证行为一致）；
   *
   * <p>- 目标存在且非空：只有 `force=true` 才允许递归清空，否则直接失败。
   */
  private Path prepareProjectRoot(ProjectConfig config) throws IOException {
    Path projectRoot = config.output().resolve(config.projectName()).normalize().toAbsolutePath();
    if (Files.exists(projectRoot)) {
      boolean notEmpty;
      try (Stream<Path> stream = Files.list(projectRoot)) {
        notEmpty = stream.findAny().isPresent();
      }
      if (notEmpty) {
        if (!config.force()) {
          throw new IllegalArgumentException(
              "target exists and is not empty: " + projectRoot + " (use --force to overwrite)");
        }
        deleteRecursively(projectRoot);
      } else {
        Files.delete(projectRoot);
      }
    }
    Files.createDirectories(projectRoot);
    return projectRoot;
  }

  /** 构建渲染上下文，集中管理后续所有模板渲染所需路径与变量。 */
  private GenerationContext buildGenerationContext(ProjectConfig config, Path projectRoot) {
    String packagePath = config.packageName().replace('.', '/');
    String appClass = toCamel(config.projectName()) + "Application";
    List<String> modules = sortedModules(config.modules());
    Map<String, Object> model = buildTemplateModel(config, packagePath, appClass, modules);
    Path mainJavaRoot = projectRoot.resolve("src/main/java").resolve(packagePath);
    Path testJavaRoot = projectRoot.resolve("src/test/java").resolve(packagePath);
    return new GenerationContext(projectRoot, mainJavaRoot, testJavaRoot, appClass, modules, model);
  }

  /**
   * 组装模板模型。
   *
   * <p>除基础字段外，还会计算“派生变量”：
   *
   * <p>- `includePulsar`：由 producer/consumer 两个开关推导；
   *
   * <p>- `p3cSkip` 与 `p3cFailOnViolation`：由 `p3cMode` 推导；
   *
   * <p>- `hasModules`：用于模板中条件渲染文案。
   */
  private Map<String, Object> buildTemplateModel(
      ProjectConfig config, String packagePath, String appClass, List<String> modules) {
    boolean includeRedis = config.modules().contains("redis");
    boolean includePulsarProducer = config.modules().contains("pulsar-producer");
    boolean includePulsarConsumer = config.modules().contains("pulsar-consumer");
    boolean includePulsar = includePulsarProducer || includePulsarConsumer;
    boolean p3cSkip = "off".equals(config.p3cMode());
    boolean p3cFailOnViolation = "strict".equals(config.p3cMode());

    Map<String, Object> model = new HashMap<>();
    model.put("projectName", config.projectName());
    model.put("groupId", config.groupId());
    model.put("artifactId", config.artifactId());
    model.put("packageName", config.packageName());
    model.put("packagePath", packagePath);
    model.put("description", config.description());
    model.put("javaVersion", config.javaVersion());
    model.put("bootVersion", config.bootVersion());
    model.put("port", String.valueOf(config.port()));
    model.put("appClass", appClass);
    model.put("includeRedis", includeRedis);
    model.put("includePulsarProducer", includePulsarProducer);
    model.put("includePulsarConsumer", includePulsarConsumer);
    model.put("includePulsar", includePulsar);
    model.put("p3cMode", config.p3cMode());
    model.put("p3cSkip", p3cSkip);
    model.put("p3cFailOnViolation", p3cFailOnViolation);
    model.put("modules", modules);
    model.put("hasModules", !modules.isEmpty());

    for (ModuleDefinition module : moduleRegistry.values()) {
      model.put(module.modelKey(), config.modules().contains(module.id()));
    }
    return model;
  }

  /** 渲染项目级文件（pom、README、资源配置等，不依赖包路径）。 */
  private void renderProjectTemplates(Configuration configuration, GenerationContext context)
      throws IOException, TemplateException {
    for (ProjectTemplateTarget templateTarget : PROJECT_TEMPLATE_TARGETS) {
      render(
          configuration,
          templateTarget.templatePath(),
          context.model(),
          context.projectRoot().resolve(templateTarget.relativeOutputPath()));
    }
  }

  /**
   * 渲染核心 Java 源码与基础测试。
   *
   * <p>这些模板不受可选模块开关影响，属于任何项目都应生成的最小骨架。
   */
  private void renderCoreSourceTemplates(Configuration configuration, GenerationContext context)
      throws IOException, TemplateException {
    render(
        configuration,
        MAIN_JAVA_TEMPLATE_ROOT + "MainApplication.java.ftl",
        context.model(),
        context.mainJavaRoot().resolve(context.appClass() + ".java"));

    renderSourceTemplateSet(
        configuration,
        context.model(),
        context.mainJavaRoot(),
        MAIN_JAVA_TEMPLATE_ROOT,
        CORE_MAIN_TEMPLATE_FILES);

    render(
        configuration,
        TEST_JAVA_TEMPLATE_ROOT + "AppTests.java.ftl",
        context.model(),
        context.testJavaRoot().resolve(context.appClass() + "Tests.java"));

    renderSourceTemplateSet(
        configuration,
        context.model(),
        context.testJavaRoot(),
        TEST_JAVA_TEMPLATE_ROOT,
        CORE_TEST_TEMPLATE_FILES);
  }

  /**
   * 按模块 ID 渲染可选模板。
   *
   * <p>模块模板既可能是主源码也可能是测试源码，通过 `testSource` 决定输出到 main/test 根目录。
   */
  private void renderModuleTemplates(Configuration configuration, GenerationContext context)
      throws IOException, TemplateException {
    for (String moduleId : context.modules()) {
      ModuleDefinition module = moduleRegistry.get(moduleId);
      if (module == null) {
        continue;
      }
      for (TemplateTarget templateTarget : module.templateTargets()) {
        Path sourceRoot = templateTarget.testSource() ? context.testJavaRoot() : context.mainJavaRoot();
        render(
            configuration,
            templateTarget.templatePath(),
            context.model(),
            sourceRoot.resolve(templateTarget.relativeOutputPath()));
      }
    }
  }

  /** 批量渲染一组相对路径模板，减少重复 `render(...)` 调用。 */
  private void renderSourceTemplateSet(
      Configuration configuration,
      Map<String, Object> model,
      Path sourceRoot,
      String templateRoot,
      List<String> relativePaths)
      throws IOException, TemplateException {
    for (String relativePath : relativePaths) {
      // 模板文件统一使用 ".ftl" 后缀，输出文件保持原始 Java/资源后缀。
      render(
          configuration,
          templateRoot + relativePath + ".ftl",
          model,
          sourceRoot.resolve(relativePath));
    }
  }

  /** 对模块列表做字典序排序，确保生成顺序稳定（便于测试与排障）。 */
  private List<String> sortedModules(Iterable<String> modules) {
    List<String> sorted = new ArrayList<>();
    for (String module : modules) {
      sorted.add(module);
    }
    sorted.sort(String::compareTo);
    return List.copyOf(sorted);
  }

  /**
   * 将项目名转换成驼峰大写类名前缀。
   *
   * <p>示例：`demo-service` -> `DemoService`，最终主类名为 `DemoServiceApplication`。
   */
  private String toCamel(String value) {
    String[] parts = value.split("[^A-Za-z0-9]+");
    StringBuilder builder = new StringBuilder();
    for (String part : parts) {
      if (part.isBlank()) {
        continue;
      }
      builder.append(Character.toUpperCase(part.charAt(0)));
      if (part.length() > 1) {
        builder.append(part.substring(1));
      }
    }
    if (builder.length() == 0) {
      return "Demo";
    }
    return builder.toString();
  }

  /** 创建 Freemarker 配置，统一模板加载根目录和异常策略。 */
  private Configuration createFreemarkerConfig() {
    Configuration configuration = new Configuration(Configuration.VERSION_2_3_33);
    configuration.setClassLoaderForTemplateLoading(getClass().getClassLoader(), "/templates");
    configuration.setDefaultEncoding(StandardCharsets.UTF_8.name());
    configuration.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
    return configuration;
  }

  /**
   * 渲染单个模板并写入目标文件。
   *
   * <p>写文件前会确保父目录存在，避免因为目录未创建导致失败。
   */
  private void render(
      Configuration configuration,
      String templatePath,
      Map<String, Object> model,
      Path outputPath)
      throws IOException, TemplateException {
    Template template = configuration.getTemplate(templatePath);
    StringWriter writer = new StringWriter();
    template.process(model, writer);
    Files.createDirectories(outputPath.getParent());
    Files.writeString(outputPath, writer.toString(), StandardCharsets.UTF_8);
  }

  /**
   * 递归删除目录（自底向上）。
   *
   * <p>文件系统遍历使用逆序删除，先删文件再删目录，避免“目录非空”错误。
   */
  private void deleteRecursively(Path path) throws IOException {
    try (Stream<Path> stream = Files.walk(path)) {
      stream
          .sorted(Comparator.reverseOrder())
          .forEach(
              entry -> {
                try {
                  Files.deleteIfExists(entry);
                } catch (IOException ex) {
                  throw new RuntimeException(ex);
                }
              });
    } catch (RuntimeException ex) {
      if (ex.getCause() instanceof IOException ioException) {
        throw ioException;
      }
      throw ex;
    }
  }

  /** 生成过程运行态上下文，避免在多方法间传递大量离散参数。 */
  private record GenerationContext(
      Path projectRoot,
      Path mainJavaRoot,
      Path testJavaRoot,
      String appClass,
      List<String> modules,
      Map<String, Object> model) {}

  /** 项目级模板映射：`模板路径 -> 生成路径`。 */
  private record ProjectTemplateTarget(String templatePath, String relativeOutputPath) {}
}
