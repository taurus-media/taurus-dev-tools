#!/usr/bin/env bash

set -euo pipefail

# Colors for logging
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INSTALL]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verify Docker exists
if ! command -v docker >/dev/null 2>&1; then
    log_error "Docker is not installed. Please install Docker for Mac first."
    exit 1
fi

# Verify git exists
if ! command -v git >/dev/null 2>&1; then
    log_error "git is not installed."
    exit 1
fi

# Create symlink into /usr/local/bin/taurus
TAURUS_SOURCE="$(pwd)/bin/taurus"
TAURUS_TARGET="/usr/local/bin/taurus"

if [[ ! -f "$TAURUS_SOURCE" ]]; then
    log_error "Taurus source not found at $TAURUS_SOURCE. Please run install.sh from the project root."
    exit 1
fi

log_info "Creating symlink /usr/local/bin/taurus..."
sudo ln -sf "$TAURUS_SOURCE" "$TAURUS_TARGET"

# Make executable
log_info "Making taurus executable..."
chmod +x "$TAURUS_SOURCE"

log_info "Installation complete! You can now use the 'taurus' command."
