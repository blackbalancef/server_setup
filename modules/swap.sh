#!/usr/bin/env bash
set -euo pipefail

# Create swap file if none exists
# Size: 2 GB (good default for 1-4 GB RAM servers)

SWAP_SIZE="2G"
SWAP_FILE="/swapfile"

if swapon --show | grep -q "$SWAP_FILE"; then
    echo "Swap already active at $SWAP_FILE, skipping"
    exit 0
fi

if [[ -f "$SWAP_FILE" ]]; then
    echo "Swap file exists but inactive, activating..."
else
    echo "Creating ${SWAP_SIZE} swap file..."
    fallocate -l "$SWAP_SIZE" "$SWAP_FILE"
fi

chmod 600 "$SWAP_FILE"
mkswap "$SWAP_FILE"
swapon "$SWAP_FILE"

# Persist across reboots
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "${SWAP_FILE} none swap sw 0 0" >> /etc/fstab
fi

echo "Swap active: $(swapon --show)"
