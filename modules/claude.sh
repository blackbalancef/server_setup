#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

REPO_RAW_URL="${REPO_RAW_URL:-https://raw.githubusercontent.com/blackbalancef/server_setup/main}"

# Install Node.js if not present (via NodeSource LTS)
if ! command -v node &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
fi

if command -v claude &>/dev/null; then
    echo "Claude Code is already installed, skipping"
else
    npm install -g @anthropic-ai/claude-code
fi

# --- Configure ccstatusline for the real user ---
REAL_USER="${SUDO_USER:-root}"
REAL_HOME=$(eval echo "~${REAL_USER}")

# ccstatusline config
CCSTATUSLINE_DIR="${REAL_HOME}/.config/ccstatusline"
mkdir -p "$CCSTATUSLINE_DIR"
curl -fsSL "${REPO_RAW_URL}/configs/ccstatusline.json" -o "${CCSTATUSLINE_DIR}/settings.json"
chown -R "${REAL_USER}:${REAL_USER}" "${CCSTATUSLINE_DIR}"

# Claude settings — add statusLine section
CLAUDE_DIR="${REAL_HOME}/.claude"
CLAUDE_SETTINGS="${CLAUDE_DIR}/settings.json"
mkdir -p "$CLAUDE_DIR"

if [[ -f "$CLAUDE_SETTINGS" ]]; then
    # Merge statusLine into existing settings
    TMPFILE=$(mktemp)
    jq '. + {"statusLine": {"type": "command", "command": "npx -y ccstatusline@latest", "padding": 0}}' \
        "$CLAUDE_SETTINGS" > "$TMPFILE" && mv "$TMPFILE" "$CLAUDE_SETTINGS"
else
    cat > "$CLAUDE_SETTINGS" <<'SETTINGS'
{
  "statusLine": {
    "type": "command",
    "command": "npx -y ccstatusline@latest",
    "padding": 0
  }
}
SETTINGS
fi

chown -R "${REAL_USER}:${REAL_USER}" "${CLAUDE_DIR}"
