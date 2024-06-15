#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")
source "${script_dir}/.flywayrc.sh"

usage() {
    echo "📋 Usage: $0 -d/--database <database> -n/--name <name>"
    echo "✅ Example: $0 -d account -n create_table_users"
    exit
}

# The script name should in lower_snake_case and include alphabet characters only (a-z)
check_script_name() {
    if [[ ! $name =~ ^[a-z_]+$ ]]; then
        echo "❗️ Invalid script name: $name. It should be in lower_snake_case and include alphabet characters only (a-z)"
        exit 1
    fi
}

check_dbname() {
    if [[ ! " ${dbnames[@]} " =~ " ${dbname} " ]]; then
        echo "❗️ Invalid database name: ${dbname}. It should be one of the following:"
        for db in "${dbnames[@]}"; do
            echo "  - ${db}"
        done
        exit 1
    fi
}

gen_sql() {
    dir="migrations/${dbname}/sql"
    file="${dir}/V${utc}__${name}.sql"

    echo "📝 Generating SQL script..."
    echo "   - Directory: ${dir}"
    echo "   - Database: ${dbname}"
    echo "   - Script: ${file}"

    if [ ! -d "$dir" ]; then
        echo "❗️ Directory not found: ${dir}"
        exit 1
    fi

    if [ -f "$file" ]; then
        echo "❗️ File already exists: ${file}"
        exit 1
    fi

    touch "$file"

    echo "✅ SQL script generated successfully!"
}

dbname=""
name=""
utc=$(date -u +"%Y%m%d%H%M%S")

# If no arguments provided, show usage
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

while [ "${1:-}" != "" ]; do
    case $1 in
        -d | --database )       shift
                                dbname=${1:-}
                                ;;
        -n | --name )           shift
                                name=${1:-}
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     echo "❗️ Invalid argument: $1"
                                usage
                                exit 1
    esac
    shift
done

check_dbname
check_script_name
gen_sql