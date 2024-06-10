#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")
source "${script_dir}/.flywayrc.sh"

stop_container