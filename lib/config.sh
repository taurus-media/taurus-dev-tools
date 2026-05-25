#!/usr/bin/env bash

set -euo pipefail

# Get the directory where the script is located
TAURUS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${TAURUS_ROOT}/config"

# Load PHP image mapping
get_php_image() {
    local php_version=$1
    local config_file="${CONFIG_DIR}/php-images.conf"
    
    if [[ ! -f "$config_file" ]]; then
        exit_with_error "Configuration file not found: $config_file"
    fi

    local image
    image=$(grep "^${php_version}=" "$config_file" | cut -d'=' -f2)
    
    if [[ -z "$image" ]]; then
        exit_with_error "Unsupported PHP version: $php_version"
    fi
    
    echo "$image"
}

# Save project metadata
save_metadata() {
    local project_path=$1
    local metadata_file="${project_path}/.taurus.env"
    shift
    
    # Clean file or create new
    : > "$metadata_file"
    
    for arg in "$@"; do
        echo "$arg" >> "$metadata_file"
    done
}

# Get database password from /data/web/.my.cnf inside container
get_db_password() {
    local container_name=$1
    local my_cnf="/data/web/.my.cnf"
    
    # Try to extract password using docker exec
    local password
    password=$(docker exec "$container_name" grep "^password[[:space:]]*=[[:space:]]*" "$my_cnf" 2>/dev/null | head -1 | cut -d'=' -f2- | sed "s/^[[:space:]]*//;s/[[:space:]]*$//;s/['\"]//g" || true)
    
    if [[ -n "$password" ]]; then
        echo "$password"
    else
        exit_with_error "Database password not found in $container_name:$my_cnf"
    fi
}
