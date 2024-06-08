# Flyway only supports x86_64 architecture, so we need to use an image with x86_64 architecture to build the Flyway image.
FROM --platform=linux/amd64 ubuntu:24.10 AS build

ARG flyway_version=10.14.0

RUN apt-get update && apt-get install -y curl

# Install Postgres server
#RUN apt-get install postgresql-16 -y \
#    && ln -s /usr/lib/postgresql/16/bin/* /usr/local/bin

# Install Flyway
RUN curl -s https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${flyway_version}/flyway-commandline-${flyway_version}-linux-x64.tar.gz | tar xvz -C /opt \
    && ln -s /opt/flyway-${flyway_version}/flyway /usr/local/bin \
    && ln -s /opt/flyway-${flyway_version}/flyway /opt/flyway

# Clean up the image
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM scratch

LABEL maintainer="Duy Nguyen" \
    version="1.0" \
    description="Postgres Flyway Migration Container for CI/CD pipeline" \
    com.vnworkday.docker.name="flyway"

COPY --from=build / /

ENTRYPOINT ["/bin/bash", "-c"]