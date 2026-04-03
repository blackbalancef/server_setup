#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Server Setup Script
# Usage: curl -fsSL https://raw.githubusercontent.com/<user>/server_setup/main/setup.sh | sudo bash
#        curl -fsSL ... | sudo bash -s -- --no-docker --no-claude
# ============================================================

REPO_RAW_URL="https://raw.githubusercontent.com/blackbalancef/server_setup/main"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }

# --- Defaults ---
INSTALL_BASE=true
INSTALL_FIREWALL=true
INSTALL_SSH_HARDEN=true
INSTALL_DOCKER=true
INSTALL_CLAUDE=true
INSTALL_GH=true
INSTALL_OHMYZSH=true
INSTALL_ZELLIJ=true
INSTALL_SWAP=true
INSTALL_SYSCTL=true
INSTALL_AUTO_UPDATES=true
INSTALL_JOURNALD=true

# --- Parse flags ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-base)       INSTALL_BASE=false ;;
        --no-firewall)   INSTALL_FIREWALL=false ;;
        --no-ssh-harden) INSTALL_SSH_HARDEN=false ;;
        --no-docker)     INSTALL_DOCKER=false ;;
        --no-claude)     INSTALL_CLAUDE=false ;;
        --no-gh)         INSTALL_GH=false ;;
        --no-ohmyzsh)    INSTALL_OHMYZSH=false ;;
        --no-zellij)     INSTALL_ZELLIJ=false ;;
        --no-swap)       INSTALL_SWAP=false ;;
        --no-sysctl)     INSTALL_SYSCTL=false ;;
        --no-auto-updates) INSTALL_AUTO_UPDATES=false ;;
        --no-journald)   INSTALL_JOURNALD=false ;;
        --help|-h)
            echo "Usage: setup.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-base        Skip apt update/upgrade and base packages"
            echo "  --no-firewall    Skip UFW firewall setup"
            echo "  --no-ssh-harden  Skip fail2ban SSH hardening"
            echo "  --no-docker      Skip Docker installation"
            echo "  --no-claude      Skip Claude Code installation"
            echo "  --no-gh          Skip gh/glab CLI installation"
            echo "  --no-ohmyzsh     Skip Oh My Zsh installation"
            echo "  --no-zellij      Skip Zellij installation"
            echo "  --no-swap        Skip swap file creation"
            echo "  --no-sysctl      Skip kernel tuning"
            echo "  --no-auto-updates Skip unattended security upgrades"
            echo "  --no-journald    Skip journald log limits"
            echo "  -h, --help       Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# --- Check root ---
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# --- Check distro ---
if [[ ! -f /etc/os-release ]]; then
    log_error "Cannot detect OS. /etc/os-release not found."
    exit 1
fi

. /etc/os-release

if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    log_error "Unsupported distro: $ID. Only Ubuntu and Debian are supported."
    exit 1
fi

log_info "Detected: $PRETTY_NAME"

# --- Download and run modules ---
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

download_module() {
    local name="$1"
    local url="${REPO_RAW_URL}/modules/${name}"
    local dest="${TMPDIR}/${name}"

    if command -v curl &>/dev/null; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget &>/dev/null; then
        wget -q "$url" -O "$dest"
    else
        log_error "Neither curl nor wget found"
        exit 1
    fi
    chmod +x "$dest"
}

run_module() {
    local name="$1"
    local label="$2"

    log_info "=== ${label} ==="
    download_module "$name"
    bash "${TMPDIR}/${name}"
    log_success "${label} — done"
    echo ""
}

# --- Execute modules ---
echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Server Setup Script             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

[[ "$INSTALL_BASE"       == true ]] && run_module "base.sh"       "Base packages"
[[ "$INSTALL_FIREWALL"   == true ]] && run_module "firewall.sh"   "UFW Firewall"
[[ "$INSTALL_SSH_HARDEN" == true ]] && run_module "ssh_harden.sh" "SSH Hardening (fail2ban)"
[[ "$INSTALL_DOCKER"     == true ]] && run_module "docker.sh"     "Docker"
[[ "$INSTALL_CLAUDE"     == true ]] && run_module "claude.sh"     "Claude Code"
[[ "$INSTALL_GH"         == true ]] && run_module "gh_glab.sh"    "GitHub/GitLab CLI"
[[ "$INSTALL_OHMYZSH"   == true ]] && run_module "ohmyzsh.sh"    "Oh My Zsh"
[[ "$INSTALL_ZELLIJ"   == true ]] && run_module "zellij.sh"     "Zellij"
[[ "$INSTALL_SWAP"     == true ]] && run_module "swap.sh"       "Swap (2 GB)"
[[ "$INSTALL_SYSCTL"   == true ]] && run_module "sysctl_tune.sh" "Kernel Tuning"
[[ "$INSTALL_AUTO_UPDATES" == true ]] && run_module "auto_updates.sh" "Unattended Upgrades"
[[ "$INSTALL_JOURNALD" == true ]] && run_module "journald.sh"   "Journald Limits"

echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      Setup complete!                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
log_info "You may need to re-login for group changes (docker) to take effect."
