#!/usr/bin/env bash

set -euo pipefail

project="${PROJECT_NAME:-vnworkday}"
  
dba_password_file="${HOME}/.pgsql/dba_password"

## Get Flyway container ID
## Usage: get_container_id
get_container_id() {
  echo "🐳 Getting Flyway container ID..."
  CONTAINER_ID=$(docker ps --filter "label=com.vnworkday.docker.name=flyway" -q)
  if [ -z "$CONTAINER_ID" ]; then
      echo "⚠️ Flyway container not found. Please run the Flyway container first."
      exit 1
  fi
  echo "🐳 Flyway container ID: $CONTAINER_ID"
  export CONTAINER_ID
}

## Get SA password from the secrets directory if not provided as an environment variable.
## Usage: get_dba_password
get_dba_password() {
  if [[ "${DBA_PASSWORD:-}" == "" ]]; then
    if [[ -e "${dba_password_file}" ]]; then
      DBA_PASSWORD=$(cat "${dba_password_file}")
      export DBA_PASSWORD
    else
      echo "⚠️ Could not read SA password from ${dba_password_file}"
      exit 1
    fi
  fi
}

## Build the Flyway container
## Usage: build_container
build_container() {
  echo "🐳 Building Flyway container..."
  get_dba_password
  docker compose --file ./ci/docker-compose.yaml --project-name "${project}" build
  echo "🐳 Flyway container built successfully."
}

## Start the Flyway container
## Usage: start_container
start_container() {
  echo "🐳 Starting Flyway container..."
  get_dba_password
  docker compose --file ./ci/docker-compose.yaml --project-name "${project}" up --detach --quiet-pull
  echo "🐳 Flyway container started successfully."
}

## Stop the Flyway container
## Usage: stop_container
stop_container() {
  echo "🐳 Stopping Flyway container..."
  get_dba_password
  docker compose --file ./ci/docker-compose.yaml --project-name "${project}" down
  echo "🐳 Flyway container stopped successfully."
}

## Run SQL command in the Flyway container
## Usage: exec_sql_cmd [sql_cmd]
## Example: exec_sql_cmd "SELECT * FROM table_name"
exec_sql_cmd() {
  sql_cmd="${1:-}"
  if [[ "${sql_cmd}" == "" ]]; then
    echo "⚠️ Please provide an SQL command."
    exit 1
  fi
  get_container_id
  get_dba_password
  docker exec "${CONTAINER_ID}" psql --username=dba --host=postgres --dbname=postgres --command="${sql_cmd}"
}

## Run SQL file in the Flyway container
## Usage: exec_sql_file [sql_file]
## Example: exec_sql_file "create_table"
exec_sql_file() {
  sql_file="${1:-}"
  if [[ "${sql_file}" == "" ]]; then
    echo "⚠️ Please provide an SQL file."
    exit 1
  fi
  shift
  get_container_id
  get_dba_password
  docker exec --workdir /migrations "${CONTAINER_ID}" psql --username=dba --host=postgres --dbname=postgres "$@" --file="${sql_file}"
}

## Run Flyway command in the Flyway container
## Usage: run_flyway [command]
## Example: run_flyway migrate -X
run_flyway() {
  echo "🐳 Running Flyway command: flyway" "$@"
  get_container_id
  docker exec --env DATABASE="${DATABASE}" --workdir /migrations "${CONTAINER_ID}" flyway "$@"
  echo "🐳 Flyway ran successfully."
}

error_report() {
  echo "🚨 Error on line $(caller)" >&2
}

## When a command fails, the ERR signal is triggered and the trap command catches it
## to execute the error_report function, which prints the error message
## and the line number where the error occurred.
trap error_report ERR