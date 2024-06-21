#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")
source "${script_dir}/.flywayrc.sh"

dbname="${1:-}"
if [[ "${dbname}" == "" ]]; then
  echo "⚠️ Please provide a database name. That should be one of the following:"
  for db in "${dbnames[@]}"; do
    echo "  - ${db}"
  done
  echo "📋 Usage: $0 account"
  echo "✅ Example: $0 account"
  exit 1
fi

run_flyway -configFiles=./migrations/"${dbname}"/flyway.toml -environment=local migrate