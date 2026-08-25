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

# Prompt for a missing value, if running interactively. Required values error
# out when left blank; optional values fall back to the given default
# (which may itself be empty) when left blank or run non-interactively.
# Usage: value=$(prompt_for_value "label" "current value" "question" [is_required] [default])
#   is_required defaults to "true"; default defaults to ""
prompt_for_value() {
    local label="$1"
    local current="$2"
    local question="$3"
    local is_required="${4:-true}"
    local default="${5:-}"

    if [[ -n "$current" ]]; then
        echo "$current"
        return 0
    fi

    if [[ ! -t 0 ]]; then
        if [[ "$is_required" == "true" ]]; then
            exit_with_error "--${label} is required"
        fi
        echo "$default"
        return 0
    fi

    local suffix=""
    if [[ "$is_required" != "true" && -n "$default" ]]; then
        suffix=" [${default}]"
    fi

    local answer
    read -r -p "$(echo -e "${YELLOW}[INPUT]${NC} ${question}${suffix}: ")" answer </dev/tty
    if [[ -z "$answer" ]]; then
        if [[ "$is_required" == "true" ]]; then
            exit_with_error "--${label} is required"
        fi
        echo "$default"
        return 0
    fi
    echo "$answer"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Expand a leading ~ in a path. Needed because tilde expansion only happens
# for literal, unquoted words during shell parsing -- not for paths that
# arrive via a variable (CLI args, prompt_for_value), so "~/foo" typed at
# --db or the interactive prompt is otherwise passed through unexpanded.
expand_path() {
    local path="$1"
    if [[ "$path" == "~" ]]; then
        echo "$HOME"
    elif [[ "$path" == "~/"* ]]; then
        echo "${HOME}${path:1}"
    else
        echo "$path"
    fi
}
