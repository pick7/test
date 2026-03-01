# Command Reference

本技能对 `java-proj-gen.jar` 采用参数透传模式，不做语义改写。

## 常用参数

- `--project-name`
- `--group-id`
- `--artifact-id`
- `--package-name`
- `--description`
- `--java-version`
- `--boot-version`
- `--boot-line`
- `--port`
- `--modules`
- `--p3c-mode`
- `--output`
- `--force`
- `--interactive`
- `--help` / `-h`

## 典型命令

```bash
./scripts/run-generator.sh \
  --project-name demo-service \
  --group-id com.acme \
  --artifact-id demo-service \
  --package-name com.acme.demoservice \
  --modules redis,pulsar-producer,pulsar-consumer \
  --p3c-mode strict \
  --output ./output
```

```bat
scripts\\run-generator.bat --project-name demo-service --group-id com.acme --artifact-id demo-service --package-name com.acme.demoservice --output .\\output
```

## 行为一致性说明

脚本最终执行的是：

```text
java -jar <resolved-jar-path> <用户原始参数>
```

因此生成结果与直接调用 `java -jar java-proj-gen.jar ...` 一致。
