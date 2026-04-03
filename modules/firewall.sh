#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get install -y ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh

ufw --force enable
