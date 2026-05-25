#!/usr/bin/env bash

set -euo pipefail

update_hosts() {
    local domain=$1
    local entry="127.0.0.1 ${domain}"
    
    if grep -q "$entry" /etc/hosts; then
        log_info "Hosts entry for $domain already exists."
    else
        log_info "Adding $domain to /etc/hosts (requires sudo)..."
        echo "$entry" | sudo tee -a /etc/hosts >/dev/null
    fi
}
