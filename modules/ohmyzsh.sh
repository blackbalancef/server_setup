#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get install -y zsh

# Install Oh My Zsh for the real user (not root)
REAL_USER="${SUDO_USER:-root}"
REAL_HOME=$(eval echo "~${REAL_USER}")

if [[ -d "${REAL_HOME}/.oh-my-zsh" ]]; then
    echo "Oh My Zsh is already installed for ${REAL_USER}, skipping"
    exit 0
fi

# Install Oh My Zsh unattended
su - "$REAL_USER" -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Set zsh as default shell
chsh -s "$(which zsh)" "$REAL_USER"
