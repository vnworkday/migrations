# Flyway only supports x86_64 architecture, so we need to use an image with x86_64 architecture to build the Flyway image.
FROM --platform=linux/amd64 ubuntu:24.10 AS build

ARG flyway_version=10.15.0

RUN apt-get update -y \
    && apt-get install wget postgresql-client -y \
    && ln -s /usr/lib/postgresql/16/bin/* /usr/local/bin

# Install Flyway
RUN wget -qO- https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/${flyway_version}/flyway-commandline-${flyway_version}-linux-x64.tar.gz | tar -xvz \
    && ln -s `pwd`/flyway-${flyway_version}/flyway /usr/local/bin

# Clean up the image
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM scratch

LABEL com.vnworkday.docker.maintainer="Duy Nguyen" \
    com.vnworkday.docker.version="1.0" \
    com.vnworkday.docker.description="Postgres Flyway Migration Container for CI/CD pipeline" \
    com.vnworkday.docker.name="flyway" \
    com.vnworkday.docker.project="vnworkday"

COPY --from=build / /

ENTRYPOINT ["/bin/bash", "-c"]