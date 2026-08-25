#!/usr/bin/env bash

set -euo pipefail

update_hosts() {
    local domain=$1
    local entry="127.0.0.1 ${domain}"
    local marker="### Taurus local hosts"

    if grep -qF "$entry" /etc/hosts; then
        log_info "Hosts entry for $domain already exists."
        return
    fi

    log_info "Adding $domain to /etc/hosts (requires sudo)..."

    if grep -qF "$marker" /etc/hosts; then
        local tmp
        tmp=$(mktemp)
        awk -v marker="$marker" -v entry="$entry" '
            { print }
            $0 == marker { print entry }
        ' /etc/hosts > "$tmp"
        sudo cp "$tmp" /etc/hosts
        rm -f "$tmp"
    else
        printf '\n%s\n%s\n' "$marker" "$entry" | sudo tee -a /etc/hosts >/dev/null
    fi
}
