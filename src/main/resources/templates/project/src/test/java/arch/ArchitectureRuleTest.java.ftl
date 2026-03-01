package ${packageName}.arch;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

/**
 * 架构规则测试：约束分层包结构与主流命名后缀。
 */
@AnalyzeClasses(packages = "${packageName}", importOptions = ImportOption.DoNotIncludeTests.class)
class ArchitectureRuleTest {

  @ArchTest
  static final ArchRule topLevelClassesShouldStayInKnownPackages =
      classes()
          .that()
          .areTopLevelClasses()
          .and()
          .resideInAPackage("${packageName}..")
          .should()
          .resideInAnyPackage(
              "${packageName}",
              "${packageName}.config..",
              "${packageName}.controller..",
              "${packageName}.service..",
              "${packageName}.repository..",
              "${packageName}.entity..",
              "${packageName}.dto..",
              "${packageName}.vo..",
              "${packageName}.exception..",
              "${packageName}.common..",
              "${packageName}.util..",
              "${packageName}.aspect..",
              "${packageName}.annotation..",
              "${packageName}.integration..",
              "${packageName}.proxy..");

  @ArchTest
  static final ArchRule controllerPackageClassesShouldEndWithController =
      classes()
          .that()
          .resideInAPackage("${packageName}.controller..")
          .and()
          .areNotInnerClasses()
          .should()
          .haveSimpleNameEndingWith("Controller");

  @ArchTest
  static final ArchRule servicePackageInterfacesShouldEndWithService =
      classes()
          .that()
          .resideInAPackage("${packageName}.service")
          .and()
          .areInterfaces()
          .should()
          .haveSimpleNameEndingWith("Service");

  @ArchTest
  static final ArchRule servicePackageClassesShouldEndWithService =
      classes()
          .that()
          .resideInAPackage("${packageName}.service")
          .and()
          .areNotInterfaces()
          .and()
          .areNotInnerClasses()
          .should()
          .haveSimpleNameEndingWith("Service")
          .allowEmptyShould(true);

  @ArchTest
  static final ArchRule serviceImplPackageClassesShouldEndWithServiceImpl =
      classes()
          .that()
          .resideInAPackage("${packageName}.service.impl..")
          .and()
          .areNotInnerClasses()
          .should()
          .haveSimpleNameEndingWith("ServiceImpl");

  @ArchTest
  static final ArchRule repositoryPackageClassesShouldEndWithRepository =
      classes()
          .that()
          .resideInAPackage("${packageName}.repository..")
          .and()
          .areNotInnerClasses()
          .should()
          .haveSimpleNameEndingWith("Repository");

  @ArchTest
  static final ArchRule entityPackageClassesShouldEndWithEntity =
      classes()
          .that()
          .resideInAPackage("${packageName}.entity..")
          .and()
          .areNotInnerClasses()
          .and()
          .doNotHaveSimpleName("BaseEntity")
          .and()
          .haveSimpleNameNotEndingWith("Builder")
          .should()
          .haveSimpleNameEndingWith("Entity");

  @ArchTest
  static final ArchRule dtoRequestClassesShouldEndWithRequest =
      classes()
          .that()
          .resideInAPackage("${packageName}.dto.request..")
          .and()
          .areNotInnerClasses()
          .should()
          .haveSimpleNameEndingWith("Request");

  @ArchTest
  static final ArchRule dtoResponseClassesShouldEndWithResponse =
      classes()
          .that()
          .resideInAPackage("${packageName}.dto.response..")
          .and()
          .areNotInnerClasses()
          .should()
          .haveSimpleNameEndingWith("Response");

  @ArchTest
  static final ArchRule proxyPackageClassesShouldUseProxySuffix =
      classes()
          .that()
          .resideInAPackage("${packageName}.proxy..")
          .and()
          .areNotInnerClasses()
          .should()
          .haveSimpleNameEndingWith("Proxy");

  @ArchTest
  static final ArchRule classesOutsideControllerPackageShouldNotUseControllerSuffix =
      noClasses()
          .that()
          .resideOutsideOfPackages("${packageName}.controller..", "${packageName}.integration..")
          .should()
          .haveSimpleNameEndingWith("Controller");
}
