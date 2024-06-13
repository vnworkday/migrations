#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")
source "${script_dir}/.flywayrc.sh"

sa_password_file="${HOME}/.pgsql/sa_password"

## Initialize SA password. If not provided, generate a new one.
## Usage: init_sa_password
init_sa_password() {
  if [[ -z "${SA_PASSWORD:-}" ]]; then
    if [[ -e "${sa_password_file}" ]]; then
      echo "🔑 Reading SA password from ${sa_password_file}..."
      SA_PASSWORD=$(cat "${sa_password_file}")
    else
      echo "🔑 Generating a new SA password..."
      SA_PASSWORD="VnW0rKd4y!$(openssl rand -base64 15 | tr -cd '[:alnum:]\n')"
    fi
    echo "🔐 SA password: ${SA_PASSWORD}"
    export SA_PASSWORD
  fi
}

## Save the SA password to the secrets directory.
## Usage: save_sa_password
save_sa_password() {
  old_password=""
  mkdir -p "${HOME}/.pgsql"
  if [[ -e "${sa_password_file}" ]]; then
    old_password=$(cat "${sa_password_file}")
  fi
  if [[ "${old_password}" != "${SA_PASSWORD}" ]]; then
    echo "${SA_PASSWORD}" > "${sa_password_file}"
    chmod 0400 "${sa_password_file}"
    echo "🔑 SA password saved successfully."
  else
    echo "🔑 SA password is the same as the old one."
  fi
}

init_sa_password
save_sa_password
build_container
start_container