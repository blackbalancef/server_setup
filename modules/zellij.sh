#!/usr/bin/env bash
set -euo pipefail

ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64) ZELLIJ_ARCH="x86_64" ;;
    arm64) ZELLIJ_ARCH="aarch64" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

LATEST=$(curl -fsSL https://api.github.com/repos/zellij-org/zellij/releases/latest | jq -r '.tag_name')
URL="https://github.com/zellij-org/zellij/releases/download/${LATEST}/zellij-${ZELLIJ_ARCH}-unknown-linux-musl.tar.gz"

curl -fsSL "$URL" -o /tmp/zellij.tar.gz
tar -xzf /tmp/zellij.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/zellij
rm -f /tmp/zellij.tar.gz
