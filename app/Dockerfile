FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre

WORKDIR /app

RUN groupadd --system astro_group \
    && useradd --system --gid astro_group --home-dir /app --shell /usr/sbin/nologin astro_user \
    && chown -R astro_user:astro_group /app

COPY --from=build /app/target/*.jar /app/astrotrack.jar

RUN chown -R astro_user:astro_group /app

USER astro_user

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/astrotrack.jar"]
