#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    htop \
    tmux \
    vim \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common
