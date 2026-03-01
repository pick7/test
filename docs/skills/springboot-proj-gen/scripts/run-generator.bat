@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM 说明：
REM 1) 本脚本只做“确保本地有 jar + 透传参数执行 jar”。
REM 2) 不改写业务参数，效果与 java -jar 一致。

if "%JPGEN_GROUP_ID%"=="" set "JPGEN_GROUP_ID=com.example"
if "%JPGEN_ARTIFACT_ID%"=="" set "JPGEN_ARTIFACT_ID=java-proj-gen"
if "%JPGEN_VERSION%"=="" set "JPGEN_VERSION=0.1.0"
if "%JPGEN_HOME%"=="" set "JPGEN_HOME=%USERPROFILE%\.codex\tools\java-proj-gen"
if "%JPGEN_JAR_PATH%"=="" set "JPGEN_JAR_PATH=%JPGEN_HOME%\%JPGEN_ARTIFACT_ID%.jar"

where mvn >nul 2>nul
if errorlevel 1 (
  echo [ERROR] mvn not found. 请先确保 Maven 可用。
  exit /b 1
)

where java >nul 2>nul
if errorlevel 1 (
  echo [ERROR] java not found. 请先确保 Java 可用。
  exit /b 1
)

if not exist "%JPGEN_JAR_PATH%" (
  if not exist "%JPGEN_HOME%" mkdir "%JPGEN_HOME%"

  echo [INFO] 未找到本地生成器 jar，开始通过 Maven 拉取: %JPGEN_GROUP_ID%:%JPGEN_ARTIFACT_ID%:%JPGEN_VERSION%

  if "%JPGEN_MVN_SETTINGS%"=="" (
    call mvn -q org.apache.maven.plugins:maven-dependency-plugin:3.6.1:copy ^
      -Dartifact=%JPGEN_GROUP_ID%:%JPGEN_ARTIFACT_ID%:%JPGEN_VERSION%:jar ^
      -DoutputDirectory="%JPGEN_HOME%" ^
      -Dmdep.stripVersion=true ^
      -Dmdep.overWrite=true
  ) else (
    call mvn -q -s "%JPGEN_MVN_SETTINGS%" org.apache.maven.plugins:maven-dependency-plugin:3.6.1:copy ^
      -Dartifact=%JPGEN_GROUP_ID%:%JPGEN_ARTIFACT_ID%:%JPGEN_VERSION%:jar ^
      -DoutputDirectory="%JPGEN_HOME%" ^
      -Dmdep.stripVersion=true ^
      -Dmdep.overWrite=true
  )

  if errorlevel 1 exit /b 1
)

if not exist "%JPGEN_JAR_PATH%" (
  echo [ERROR] jar 拉取后仍不存在: %JPGEN_JAR_PATH%
  exit /b 1
)

REM 关键：参数原样透传给 jar，保证行为与直接 java -jar 一致。
java -jar "%JPGEN_JAR_PATH%" %*
exit /b %ERRORLEVEL%
