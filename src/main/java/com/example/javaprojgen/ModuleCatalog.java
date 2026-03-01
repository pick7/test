package com.example.javaprojgen;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 可选模块目录。
 *
 * <p>这里集中维护“模块 ID -> 模板集合”的映射，避免散落在生成流程代码里。
 *
 * <p>新增模块时，只需：
 *
 * <p>1) 在 `build()` 中注册一个 `ModuleDefinition`；
 *
 * <p>2) 给出模块提示文案、模板变量键、以及模板输出清单；
 *
 * <p>3) 在模板中使用对应变量（如 `includeRedis`）控制依赖和配置段。
 */
final class ModuleCatalog {

  private static final Map<String, ModuleDefinition> MODULES = build();

  private ModuleCatalog() {}

  /** 获取只读模块注册表。 */
  static Map<String, ModuleDefinition> modules() {
    return MODULES;
  }

  /** 构建默认模块注册表（顺序保留，便于交互模式按固定顺序提示）。 */
  private static Map<String, ModuleDefinition> build() {
    LinkedHashMap<String, ModuleDefinition> modules = new LinkedHashMap<>();

    register(
        modules,
        new ModuleDefinition(
            "redis",
            "Enable Redis integration",
            "includeRedis",
            List.of(
                new TemplateTarget(
                    "project/src/main/java/service/DemoRedisValueService.java.ftl",
                    "service/DemoRedisValueService.java",
                    false),
                new TemplateTarget(
                    "project/src/main/java/controller/DemoRedisController.java.ftl",
                    "controller/DemoRedisController.java",
                    false),
                new TemplateTarget(
                    "project/src/test/java/controller/DemoRedisControllerTest.java.ftl",
                    "controller/DemoRedisControllerTest.java",
                    true),
                new TemplateTarget(
                    "project/src/test/java/service/DemoRedisValueServiceTest.java.ftl",
                    "service/DemoRedisValueServiceTest.java",
                    true))));

    register(
        modules,
        new ModuleDefinition(
            "pulsar-producer",
            "Enable Pulsar producer",
            "includePulsarProducer",
            List.of(
                new TemplateTarget(
                    "project/src/main/java/integration/pulsar/DemoPulsarProduceService.java.ftl",
                    "integration/pulsar/DemoPulsarProduceService.java",
                    false),
                new TemplateTarget(
                    "project/src/main/java/integration/pulsar/DemoPulsarProducerController.java.ftl",
                    "integration/pulsar/DemoPulsarProducerController.java",
                    false),
                new TemplateTarget(
                    "project/src/test/java/integration/pulsar/DemoPulsarProducerControllerTest.java.ftl",
                    "integration/pulsar/DemoPulsarProducerControllerTest.java",
                    true))));

    register(
        modules,
        new ModuleDefinition(
            "pulsar-consumer",
            "Enable Pulsar consumer",
            "includePulsarConsumer",
            List.of(
                new TemplateTarget(
                    "project/src/main/java/integration/pulsar/DemoPulsarConsumeListener.java.ftl",
                    "integration/pulsar/DemoPulsarConsumeListener.java",
                    false),
                new TemplateTarget(
                    "project/src/test/java/integration/pulsar/DemoPulsarConsumeListenerTest.java.ftl",
                    "integration/pulsar/DemoPulsarConsumeListenerTest.java",
                    true))));

    return Collections.unmodifiableMap(modules);
  }

  /** 注册单个模块定义。 */
  private static void register(
      Map<String, ModuleDefinition> modules, ModuleDefinition moduleDefinition) {
    modules.put(moduleDefinition.id(), moduleDefinition);
  }
}

/**
 * 模块定义。
 *
 * @param id 命令行中使用的模块 ID（如 `redis`）
 * @param promptLabel 交互模式展示给用户的提示文案
 * @param modelKey 写入模板模型中的布尔变量名
 * @param templateTargets 该模块需要渲染的模板集合
 */
record ModuleDefinition(
    String id, String promptLabel, String modelKey, List<TemplateTarget> templateTargets) {}

/**
 * 模板目标定义。
 *
 * @param templatePath 模板文件路径（位于 `/templates` 下）
 * @param relativeOutputPath 输出文件相对包根路径
 * @param testSource 是否输出到 `src/test/java`，否则输出到 `src/main/java`
 */
record TemplateTarget(String templatePath, String relativeOutputPath, boolean testSource) {}
