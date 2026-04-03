#!/usr/bin/env bash
set -euo pipefail

# Limit journald log storage to prevent disk exhaustion

CONF="/etc/systemd/journald.conf.d/limits.conf"
mkdir -p "$(dirname "$CONF")"

cat > "$CONF" << 'EOF'
[Journal]
SystemMaxUse=500M
SystemMaxFileSize=50M
MaxRetentionSec=30day
Compress=yes
EOF

systemctl restart systemd-journald

echo "Journald limited to 500 MB / 30 days"
