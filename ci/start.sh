#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")
source "${script_dir}/.flywayrc.sh"

dba_password_file="${HOME}/.pgsql/dba_password"

## Initialize SA password. If not provided, generate a new one.
## Usage: init_dba_password
init_dba_password() {
  if [[ -z "${DBA_PASSWORD:-}" ]]; then
    if [[ -e "${dba_password_file}" ]]; then
      echo "🔑 Reading SA password from ${dba_password_file}..."
      DBA_PASSWORD=$(cat "${dba_password_file}")
    else
      echo "🔑 Generating a new SA password..."
      DBA_PASSWORD="VnW0rKd4y!$(openssl rand -base64 15 | tr -cd '[:alnum:]\n')"
    fi
    echo "🔐 SA password: ${DBA_PASSWORD}"
    export DBA_PASSWORD
  fi
}

## Save the SA password to the secrets directory.
## Usage: save_dba_password
save_dba_password() {
  old_password=""
  mkdir -p "${HOME}/.pgsql"
  if [[ -e "${dba_password_file}" ]]; then
    old_password=$(cat "${dba_password_file}")
  fi
  if [[ "${old_password}" != "${DBA_PASSWORD}" ]]; then
    echo "${DBA_PASSWORD}" > "${dba_password_file}"
    chmod 0400 "${dba_password_file}"
    echo "🔑 SA password saved successfully."
  else
    echo "🔑 SA password is the same as the old one."
  fi
}

init_dba_password
save_dba_password
build_container
start_container