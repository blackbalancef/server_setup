#!/usr/bin/env bash
set -euo pipefail

# Kernel tuning for server workloads
# Applied immediately and persisted via /etc/sysctl.d/

CONF="/etc/sysctl.d/99-server-tune.conf"

cat > "$CONF" << 'EOF'
# --- Memory ---
# Prefer RAM over swap; only swap under pressure
vm.swappiness = 10
# Reclaim dentry/inode caches less aggressively
vm.vfs_cache_pressure = 50
# Allow overcommit with heuristic (default, safe for most workloads)
vm.overcommit_memory = 0

# --- Network: connection handling ---
# Reuse TIME_WAIT sockets for new connections
net.ipv4.tcp_tw_reuse = 1
# Faster detection of dead connections
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 5
# Larger backlog for high-traffic servers
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# --- Network: buffers ---
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# --- Network: congestion ---
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# --- File descriptors ---
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288

# --- Security ---
# Ignore ICMP redirects (prevent MITM)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
# ip_forward left to Docker/container runtime if installed
EOF

sysctl --system > /dev/null 2>&1

echo "Sysctl tuning applied: $CONF"

# Enable BBR (requires kernel 4.9+)
if modprobe tcp_bbr 2>/dev/null; then
    echo "TCP BBR congestion control enabled"
else
    echo "Warning: BBR not available on this kernel, falling back to default"
    sed -i '/tcp_congestion_control/d' "$CONF"
    sed -i '/default_qdisc/d' "$CONF"
    sysctl --system > /dev/null 2>&1
fi

# Raise ulimits for current and future sessions
LIMITS_CONF="/etc/security/limits.d/99-server-tune.conf"
cat > "$LIMITS_CONF" << 'EOF'
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF

echo "File descriptor limits raised: $LIMITS_CONF"
