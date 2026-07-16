# syntax=docker/dockerfile:1

# =========================
# Stage 1: Build the WAR
# =========================
FROM maven:3.9.16-eclipse-temurin-8-noble AS builder

WORKDIR /build

COPY pom.xml .
COPY src ./src

RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -ntp clean package


# =========================
# Stage 2: Run with Tomcat
# =========================
FROM tomcat:9.0.120-jre8-temurin-noble AS runtime


# Apply available Ubuntu security fixes, then remove runtime tools
# that are not required by the application.
RUN apt-get update \
    && apt-get install -y --no-install-recommends --only-upgrade \
        curl \
        libcurl4t64 \
        wget \
    && apt-get purge -y \
        curl \
        wget \
    && rm -rf /var/lib/apt/lists/*
    
RUN rm -rf "${CATALINA_HOME}/webapps/"* \
    && groupadd --system tomcat \
    && useradd \
        --system \
        --gid tomcat \
        --home-dir "${CATALINA_HOME}" \
        --shell /usr/sbin/nologin \
        tomcat \
    && mkdir -p \
        "${CATALINA_HOME}/webapps" \
        "${CATALINA_HOME}/logs" \
        "${CATALINA_HOME}/temp" \
        "${CATALINA_HOME}/work" \
        "${CATALINA_HOME}/tmpFiles" \
    && chown -R tomcat:tomcat \
        "${CATALINA_HOME}/webapps" \
        "${CATALINA_HOME}/logs" \
        "${CATALINA_HOME}/temp" \
        "${CATALINA_HOME}/work" \
        "${CATALINA_HOME}/tmpFiles"

COPY --from=builder \
    --chown=tomcat:tomcat \
    /build/target/vprofile-v2.war \
    "${CATALINA_HOME}/webapps/ROOT.war"

USER tomcat:tomcat

EXPOSE 8080

CMD ["catalina.sh", "run"]