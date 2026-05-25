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

# Get database password from ~/.my.cnf
get_db_password() {
    local my_cnf="$HOME/.my.cnf"
    if [[ -f "$my_cnf" ]]; then
        # Simple parser for password under [client] or [mysql]
        # We'll look for password=...
        local password
        password=$(grep "^password=" "$my_cnf" | head -1 | cut -d'=' -f2 | sed "s/['\"]//g")
        if [[ -n "$password" ]]; then
            echo "$password"
            return
        fi
    fi
    # Default Hypernode password if not found in .my.cnf
    echo "insecure_db_password"
}
