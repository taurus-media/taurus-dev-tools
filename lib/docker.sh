#!/usr/bin/env bash

set -euo pipefail

run_container() {
    local container_name=$1
    local image=$2
    local project_path=$3
    
    # Check if container already exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_warn "Container $container_name already exists. Removing it..."
        docker rm -f "$container_name" >/dev/null
    fi
    
    log_info "Starting Hypernode container $container_name..."
    
    # Run container with static ports
    # Hypernode images use 80, 443, 3306, 22
    
    docker run -d \
        --name "$container_name" \
        -v "${project_path}:/data/web/magento2" \
        -p 80:80 -p 443:443 -p 3306:3306 -p 22:22 \
        "$image" >/dev/null
        
    # Wait for container to be ready (approximate)
    # We will wait more robustly for MySQL in the database library
    sleep 10
}

get_container_port() {
    local container_name=$1
    local internal_port=$2
    docker port "$container_name" "$internal_port" | cut -d':' -f2
}

configure_vhosts() {
    local container_name=$1
    local domain=$2
    
    log_info "Configuring Hypernode vhosts for $domain..."
    docker exec "$container_name" hypernode-manage-vhosts "$domain" --default >/dev/null
}
