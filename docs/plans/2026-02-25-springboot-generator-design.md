# Spring Boot 生成器设计（分层 CRUD 版）

## 目标

生成一个可直接运行的 Spring Boot 项目，并固定产出完整分层结构：

- `config`
- `controller`
- `service` / `service.impl`
- `repository`
- `entity`
- `dto.request` / `dto.response`
- `vo`
- `exception`
- `common.result` / `common.constant` / `common.enums`
- `util`
- `aspect`
- `annotation`

同时内置一个简单 `User` CRUD Demo。

## 固定与可选

- 固定：分层目录、PostgreSQL CRUD Demo、H2 测试、JaCoCo 100%、单元 + E2E
- 可选：`redis`、`pulsar-producer`、`pulsar-consumer`（通过 CLI `--modules`）

## 数据库策略

- 运行环境：PostgreSQL（`application.yml`）
- 测试环境：H2 内存库（`application-test.yml`，PostgreSQL 兼容模式）

## 质量门禁

在生成项目 `pom.xml` 中内置 JaCoCo 校验：

- `INSTRUCTION` 覆盖率 `100%`
- `LINE` 覆盖率 `100%`
- `METHOD` 覆盖率 `100%`

并在 `verify` 阶段执行 `report + check`。

## 测试策略

生成项目内置三类测试：

- `contextLoads` 启动测试
- Controller 层 CRUD 流测试（MockMvc）
- E2E HTTP 测试（RANDOM_PORT + TestRestTemplate）

## 实现方式

- 生成器语言：Java
- 模板引擎：FreeMarker
- CLI：Picocli
- 入口：`src/main/java/com/example/javaprojgen/GeneratorMain.java`
- 模板目录：`src/main/resources/templates/project`
