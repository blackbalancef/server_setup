#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

BASE_PACKAGES=(
    curl
    wget
    git
    unzip
    htop
    tmux
    vim
    jq
    ca-certificates
    gnupg
    lsb-release
)

# software-properties-common is unavailable in Debian 13+ (trixie)
. /etc/os-release
if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" && "${VERSION_ID:-99}" -lt 13 ]]; then
    BASE_PACKAGES+=( software-properties-common )
fi

apt-get install -y "${BASE_PACKAGES[@]}"
