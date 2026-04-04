#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# --- GitHub CLI (gh) ---
if ! command -v gh &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list

    apt-get update
    apt-get install -y gh
fi

# --- GitLab CLI (glab) ---
if ! command -v glab &>/dev/null; then
    GLAB_VERSION=$(curl -fsSL "https://gitlab.com/api/v4/projects/34675721/releases/permalink/latest" | jq -r '.tag_name' | sed 's/^v//')
    GLAB_ARCH=$(dpkg --print-architecture)
    curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${GLAB_ARCH}.deb" \
        -o /tmp/glab.deb
    dpkg -i /tmp/glab.deb
    rm -f /tmp/glab.deb
fi
