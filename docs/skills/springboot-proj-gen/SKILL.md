---
name: springboot-proj-gen
description: 通过公司 Maven 仓库拉取并执行 java-proj-gen.jar，生成 Spring Boot 项目骨架。适用于需要按参数生成可运行项目（含可选模块 redis/pulsar、p3c 模式开关）的场景。
---

# Spring Boot Project Generator (Offline-Install-Free)

本技能用于调用 `java-proj-gen.jar` 生成项目，不要求在当前工作区安装技能，也不要求手动预置 jar。

## 触发场景

- 用户要求“生成一个 Spring Boot 脚手架/项目模板”
- 用户需要选择可选模块（如 `redis`、`pulsar-producer`、`pulsar-consumer`）
- 用户需要生成后可直接运行的项目

## 关键约束

1. 必须调用 jar，不手写生成结果。
2. 必须将用户输入参数原样透传给 jar，不能私自改写参数语义。
3. 若本地缺少 jar，通过公司 Maven 仓库拉取（依赖用户已有 Maven 配置）。
4. 输出效果应与直接执行 `java -jar java-proj-gen.jar ...` 一致。

## 执行步骤

1. 收集参数（按用户要求）：
- `--project-name`
- `--group-id`
- `--artifact-id`
- `--package-name`
- `--boot-version`
- `--boot-line`
- `--modules`
- `--p3c-mode`
- `--output`
- `--force`（按需）

2. 选择系统脚本执行：
- macOS/Linux：`scripts/run-generator.sh`
- Windows：`scripts/run-generator.bat`

3. 调用示例（macOS/Linux）：

```bash
./scripts/run-generator.sh \
  --project-name demo-service \
  --group-id com.acme \
  --artifact-id demo-service \
  --package-name com.acme.demoservice \
  --modules redis,pulsar-producer \
  --p3c-mode strict \
  --output ./output
```

4. 生成后建议输出：

```bash
cd <生成目录>/<project-name>
mvn verify
mvn spring-boot:run
```

## 环境变量（可选）

- `JPGEN_GROUP_ID`（默认 `com.example`）
- `JPGEN_ARTIFACT_ID`（默认 `java-proj-gen`）
- `JPGEN_VERSION`（默认 `0.1.0`）
- `JPGEN_HOME`（默认 `~/.codex/tools/java-proj-gen` 或 `%USERPROFILE%\.codex\tools\java-proj-gen`）
- `JPGEN_JAR_PATH`（显式指定 jar 路径）
- `JPGEN_MVN_SETTINGS`（显式指定 Maven settings.xml）

## 兼容性说明

- macOS/Linux：`bash` + `mvn` + `java`
- Windows：`cmd` + `mvn` + `java`
- 无管理员权限可运行（前提：本机已有可用 `mvn` 与 `java`）

## 参考

- 参数参考：`references/command-reference.md`
