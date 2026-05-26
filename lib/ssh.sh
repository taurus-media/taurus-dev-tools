#!/usr/bin/env bash

set -euo pipefail

get_public_key_path() {
    # Try to find a public key
    for key in id_ed25519.pub id_rsa.pub id_ecdsa.pub id_dsa.pub; do
        if [[ -f "${HOME}/.ssh/${key}" ]]; then
            echo "${HOME}/.ssh/${key}"
            return 0
        fi
    done
    return 1
}

