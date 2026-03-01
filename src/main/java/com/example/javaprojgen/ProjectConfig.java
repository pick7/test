package com.example.javaprojgen;

import java.nio.file.Path;
import java.util.Set;

/**
 * 项目生成配置模型。
 *
 * <p>该 record 是生成流程的单一输入，约束“参数解析/校验”与“文件生成”之间的边界。
 *
 * @param projectName 生成目录名，同时用于推导主类名
 * @param groupId Maven groupId
 * @param artifactId Maven artifactId
 * @param packageName Java 根包名
 * @param description 项目描述
 * @param javaVersion Java 版本（如 17）
 * @param bootVersion Spring Boot 具体版本（如 3.2.12）
 * @param bootLine Spring Boot 版本线（如 3.2，`*` 表示跳过线校验）
 * @param port 服务端口
 * @param modules 启用的可选模块集合
 * @param p3cMode p3c 模式：strict/advisory/off
 * @param output 输出目录（项目会生成在该目录下的 `projectName` 子目录）
 * @param force 当目标目录非空时是否允许覆盖
 */
record ProjectConfig(
    String projectName,
    String groupId,
    String artifactId,
    String packageName,
    String description,
    String javaVersion,
    String bootVersion,
    String bootLine,
    int port,
    Set<String> modules,
    String p3cMode,
    Path output,
    boolean force) {}
