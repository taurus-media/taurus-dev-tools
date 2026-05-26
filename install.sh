#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/taurus-media/taurus-dev-tools.git"
INSTALL_DIR="$HOME/.taurus-dev-tools"
BIN_LINK="/usr/local/bin/taurus"

echo "🚀 Installing Taurus Dev Tools..."

# Verify dependencies
for cmd in git docker curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Missing dependency: $cmd"
        exit 1
    fi
done

# Remove old installation
if [ -d "$INSTALL_DIR" ]; then
    echo "📦 Updating existing installation..."
    rm -rf "$INSTALL_DIR"
fi

# Clone repository
git clone "$REPO_URL" "$INSTALL_DIR"

# Make executable
chmod +x "$INSTALL_DIR/bin/taurus"

# Create global symlink
echo "🔗 Creating global taurus command..."

sudo ln -sf "$INSTALL_DIR/bin/taurus" "$BIN_LINK"

echo ""
echo "✅ Taurus Dev Tools installed successfully!"
echo ""
echo "Run:"
echo "  taurus --help"
echo ""