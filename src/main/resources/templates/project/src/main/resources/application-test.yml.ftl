spring:
  datasource:
    url: <#noparse>${TEST_DB_URL:jdbc:postgresql://localhost:5432/postgres_test}</#noparse>
    username: <#noparse>${TEST_DB_USERNAME:postgres}</#noparse>
    password: <#noparse>${TEST_DB_PASSWORD:postgres}</#noparse>
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
    show-sql: false
  flyway:
    enabled: true
