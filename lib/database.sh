#!/usr/bin/env bash

set -euo pipefail

create_database() {
    local container_name=$1
    local db_name=$2
    
    log_info "Waiting for MySQL in $container_name to be ready..."
    local max_attempts=30
    local attempt=1
    while ! docker exec "$container_name" mysqladmin ping -h localhost --silent >/dev/null 2>&1; do
        if (( attempt >= max_attempts )); then
            exit_with_error "MySQL failed to become ready in $container_name after $max_attempts attempts."
        fi
        attempt=$((attempt + 1))
        sleep 2
    done

    log_info "Creating database $db_name..."
    docker exec "$container_name" mysql -e "CREATE DATABASE IF NOT EXISTS \`${db_name}\`;"
}

import_database() {
    local container_name=$1
    local db_name=$2
    local dump_path=$3
    
    if [[ ! -f "$dump_path" ]]; then
        log_warn "Database dump not found: $dump_path. Skipping import."
        return
    fi
    
    log_info "Importing database dump $dump_path..."
    
    if [[ "$dump_path" == *.tar.gz ]]; then
        tar -xOzf "$dump_path" | docker exec -i "$container_name" mysql "$db_name"
    elif [[ "$dump_path" == *.gz ]]; then
        gunzip -c "$dump_path" | docker exec -i "$container_name" mysql "$db_name"
    else
        docker exec -i "$container_name" mysql "$db_name" < "$dump_path"
    fi
}
