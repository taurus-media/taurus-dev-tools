#!/usr/bin/env bash

set -euo pipefail

configure_ssh_access() {
    local container_name=$1
    local pub_key_path="${HOME}/.ssh/id_rsa.pub"
    
    if [[ ! -f "$pub_key_path" ]]; then
        log_warn "Public key $pub_key_path not found. Skipping SSH access configuration."
        return
    fi
    
    local pub_key
    pub_key=$(cat "$pub_key_path")
    
    log_info "Configuring SSH access for 'app' user in container..."
    
    docker exec "$container_name" sudo -u app mkdir -p /data/web/.ssh
    docker exec "$container_name" sudo -u app bash -c "echo '$pub_key' >> /data/web/.ssh/authorized_keys"
    docker exec "$container_name" sudo -u app chmod 700 /data/web/.ssh
    docker exec "$container_name" sudo -u app chmod 600 /data/web/.ssh/authorized_keys
    
    log_info "Starting SSH service..."
    docker exec "$container_name" service ssh start >/dev/null 2>&1 || true
}
