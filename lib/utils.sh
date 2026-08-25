#!/usr/bin/env bash

set -euo pipefail

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

exit_with_error() {
    log_error "$1"
    exit 1
}

# Prompt for a missing required value, if running interactively.
# Usage: value=$(prompt_for_value "label" "current value")
prompt_for_value() {
    local label="$1"
    local current="$2"
    local question="$3"

    if [[ -n "$current" ]]; then
        echo "$current"
        return 0
    fi

    if [[ ! -t 0 ]]; then
        exit_with_error "--${label} is required"
    fi

    local answer
    read -r -p "$(echo -e "${YELLOW}[INPUT]${NC} ${question}: ")" answer </dev/tty
    if [[ -z "$answer" ]]; then
        exit_with_error "--${label} is required"
    fi
    echo "$answer"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}
