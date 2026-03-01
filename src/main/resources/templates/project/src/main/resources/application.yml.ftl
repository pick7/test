spring:
  application:
    name: ${projectName}
<#if includePulsar>
  pulsar:
    client:
      service-url: <#noparse>${PULSAR_SERVICE_URL:pulsar://localhost:6650}</#noparse>
</#if>
<#if includeRedis>
  data:
    redis:
      host: <#noparse>${REDIS_HOST:localhost}</#noparse>
      port: <#noparse>${REDIS_PORT:6379}</#noparse>
</#if>
  datasource:
    url: <#noparse>${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/postgres}</#noparse>
    username: <#noparse>${SPRING_DATASOURCE_USERNAME:postgres}</#noparse>
    password: <#noparse>${SPRING_DATASOURCE_PASSWORD:postgres}</#noparse>
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

server:
  port: ${port}

management:
  endpoints:
    web:
      exposure:
        include: health,info
  health:
<#if includeRedis>
    redis:
      enabled: <#noparse>${APP_REDIS_HEALTH_ENABLED:${app.redis.enabled:false}}</#noparse>
</#if>
<#if includePulsar>
    pulsar:
      enabled: <#noparse>${APP_PULSAR_HEALTH_ENABLED:${app.pulsar.producer.enabled:false}}</#noparse>
</#if>

<#if hasModules>
app:
<#if includeRedis>
  redis:
    enabled: <#noparse>${APP_REDIS_ENABLED:false}</#noparse>
</#if>
<#if includePulsar>
  pulsar:
<#if includePulsarProducer>
    producer:
      enabled: <#noparse>${APP_PULSAR_PRODUCER_ENABLED:false}</#noparse>
      topic: <#noparse>${APP_PULSAR_PRODUCER_TOPIC:demo-topic}</#noparse>
</#if>
<#if includePulsarConsumer>
    consumer:
      enabled: <#noparse>${APP_PULSAR_CONSUMER_ENABLED:false}</#noparse>
      topic: <#noparse>${APP_PULSAR_CONSUMER_TOPIC:demo-topic}</#noparse>
      subscription: <#noparse>${APP_PULSAR_CONSUMER_SUBSCRIPTION:demo-subscription}</#noparse>
</#if>
</#if>
</#if>
