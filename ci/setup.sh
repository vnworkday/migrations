#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")
source "${script_dir}/.flywayrc.sh"

db_names=(
  "account"
)

setup_database() {
  dbname="${1:-}"
  if [[ "${dbname}" == "" ]]; then
    echo "⚠️ Please provide a database name."
    exit 1
  fi
  schema="${dbname}app"
  username="sa_${dbname}"
  echo "🚀 Setting up the database for ${dbname}..."
  exec_sql_file "ci/setup.sql" -v username="${username}" -v password="${SA_PASSWORD}" -v dbname="${dbname}" -v schema="${schema}"
  echo "🚀 Database ${dbname} setup completed."
}

get_sa_password

for db in "${db_names[@]}"; do
  setup_database "${db}"
done