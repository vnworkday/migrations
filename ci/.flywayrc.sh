set -e

## Formatting variables
## Usage: echo "${bold}Bold text${normal}"
bold=$(tput bold 2>/dev/null || echo "")
reset=$(tput sgr0 2>/dev/null || echo "")

project="${PROJECT_NAME:vnworkday}"
db_names=(
  "account"
  "workforce"
)
  
sa_password_file="${HOME}/.pgsql/sa_password"

## Get Flyway container ID
## Usage: get_container_id
get_container_id() {
  echo "🐳 Getting Flyway container ID..."
  CONTAINER_ID=$(podman ps --filter "label=com.vnworkday.docker.name=flyway" --filter "label=com.vnworkday.project=${PROJECT_NAME}" -q)
  if [ -z "$CONTAINER_ID" ]; then
      echo "⚠️ Flyway container not found. Please run the Flyway container first."
      exit 1
  fi
  echo "🐳 Flyway container ID: $CONTAINER_ID"
  export CONTAINER_ID
}

## Get SA password from the secrets directory if not provided as an environment variable.
## Usage: get_sa_password
get_sa_password() {
  echo "🔑 Getting SA password..."
  if [[ "${SA_PASSWORD}" == "" ]]; then
    if [[ -e "${sa_password_file}" ]]; then
      SA_PASSWORD=$(cat "${sa_password_file}")
      export SA_PASSWORD
    else
      echo "⚠️ Could not read SA password from ${sa_password_file}"
      exit 1
    fi
  fi
}

## Build the Flyway container
## Usage: build_container
build_container() {
  echo "🐳 Building Flyway container..."
  get_sa_password
  podman compose --file ./ci/docker-compose.yaml --project-name "${project}" build
  echo "🐳 Flyway container built successfully."
}

## Start the Flyway container
## Usage: start_container
start_container() {
  echo "🐳 Starting Flyway container..."
  get_sa_password
  podman compose --file ./ci/docker-compose.yaml --project-name "${project}" up --detach --quiet-pull
  echo "🐳 Flyway container started successfully."
}

## Stop the Flyway container
## Usage: stop_container
stop_container() {
  echo "🐳 Stopping Flyway container..."
  get_sa_password
  podman compose --file ./ci/docker-compose.yaml --project-name "${project}" down
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
  get_sa_password
  podman exec "${CONTAINER_ID}" psql --username=postgres --dbname="${project}" --command="${sql_cmd}"
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
  get_container_id
  get_sa_password
  podman cp ./ci/"${sql_file}".sql "${CONTAINER_ID}:/tmp/${sql_file}.sql"
  podman exec "${CONTAINER_ID}" psql --username=postgres --dbname="${project}" "$@" --file="/tmp/${sql_file}.sql"
}

## Run Flyway command in the Flyway container
## Usage: run_flyway [command]
## Example: run_flyway migrate -X
run_flyway() {
  echo "🐳 Running Flyway command: flyway" "$@"
  get_container_id
  podman exec --env DATABASE="${DATABASE}" --workdir /migrations "${CONTAINER_ID}" flyway "$@"
  echo "🐳 Flyway ran successfully."
}

error_report() {
  echo "🚨 Error on line $(caller)" >&2
}

## When a command fails, the ERR signal is triggered and the trap command catches it
## to execute the error_report function, which prints the error message
## and the line number where the error occurred.
trap error_report ERR