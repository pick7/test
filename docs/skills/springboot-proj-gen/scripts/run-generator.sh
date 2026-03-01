#!/usr/bin/env bash
set -euo pipefail

# 说明：
# 1) 本脚本只负责“确保本地有 jar + 透传参数执行 jar”；
# 2) 不改写业务参数，保证与直接 java -jar 的效果一致。

JPGEN_GROUP_ID="${JPGEN_GROUP_ID:-com.example}"
JPGEN_ARTIFACT_ID="${JPGEN_ARTIFACT_ID:-java-proj-gen}"
JPGEN_VERSION="${JPGEN_VERSION:-0.1.0}"
JPGEN_HOME="${JPGEN_HOME:-$HOME/.codex/tools/java-proj-gen}"
JPGEN_JAR_PATH="${JPGEN_JAR_PATH:-$JPGEN_HOME/${JPGEN_ARTIFACT_ID}.jar}"
JPGEN_MVN_SETTINGS="${JPGEN_MVN_SETTINGS:-}"

if ! command -v mvn >/dev/null 2>&1; then
  echo "[ERROR] mvn not found. 请先确保 Maven 可用。" >&2
  exit 1
fi

if ! command -v java >/dev/null 2>&1; then
  echo "[ERROR] java not found. 请先确保 Java 可用。" >&2
  exit 1
fi

ensure_jar() {
  if [[ -f "$JPGEN_JAR_PATH" ]]; then
    return 0
  fi

  mkdir -p "$JPGEN_HOME"
  echo "[INFO] 未找到本地生成器 jar，开始通过 Maven 拉取: ${JPGEN_GROUP_ID}:${JPGEN_ARTIFACT_ID}:${JPGEN_VERSION}"

  local -a mvn_args
  mvn_args=(-q)
  if [[ -n "$JPGEN_MVN_SETTINGS" ]]; then
    mvn_args+=(-s "$JPGEN_MVN_SETTINGS")
  fi

  mvn "${mvn_args[@]}" \
    org.apache.maven.plugins:maven-dependency-plugin:3.6.1:copy \
    -Dartifact="${JPGEN_GROUP_ID}:${JPGEN_ARTIFACT_ID}:${JPGEN_VERSION}:jar" \
    -DoutputDirectory="$JPGEN_HOME" \
    -Dmdep.stripVersion=true \
    -Dmdep.overWrite=true

  if [[ ! -f "$JPGEN_JAR_PATH" ]]; then
    echo "[ERROR] jar 拉取后仍不存在: $JPGEN_JAR_PATH" >&2
    exit 1
  fi
}

ensure_jar

# 关键：参数原样透传给 jar，保证行为与直接 java -jar 一致。
exec java -jar "$JPGEN_JAR_PATH" "$@"
