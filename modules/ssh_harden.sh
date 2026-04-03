#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get install -y fail2ban

cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
EOF

# --- SSH keepalive: prevent idle disconnections ---
SSHD_CONF="/etc/ssh/sshd_config.d/99-keepalive.conf"
mkdir -p "$(dirname "$SSHD_CONF")"

cat > "$SSHD_CONF" << 'EOF'
# Send keepalive every 60s, drop after 3 missed replies (3 min timeout)
ClientAliveInterval 60
ClientAliveCountMax 3
# Longer login grace period
LoginGraceTime 120
# Allow up to 10 concurrent unauthenticated connections (default is 10:30:100)
MaxStartups 10:30:100
# Increase max sessions per connection
MaxSessions 10
# Disable TCP keepalive at OS level — SSH keepalive is more reliable
TCPKeepAlive no
EOF

systemctl enable fail2ban
systemctl restart fail2ban
sshd -t && systemctl reload sshd
