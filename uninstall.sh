#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Server Uninstall Script
# Reverses changes made by setup.sh
# Usage: sudo bash uninstall.sh [OPTIONS]
# ============================================================

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

# --- Defaults: remove everything ---
REMOVE_BASE=true
REMOVE_FIREWALL=true
REMOVE_SSH_HARDEN=true
REMOVE_DOCKER=true
REMOVE_CLAUDE=true
REMOVE_GH=true
REMOVE_OHMYZSH=true
REMOVE_ZELLIJ=true
REMOVE_SWAP=true
REMOVE_SYSCTL=true
REMOVE_AUTO_UPDATES=true
REMOVE_JOURNALD=true

ONLY_MODE=false
FORCE=false

# --- Parse flags ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-base)         REMOVE_BASE=false ;;
        --no-firewall)     REMOVE_FIREWALL=false ;;
        --no-ssh-harden)   REMOVE_SSH_HARDEN=false ;;
        --no-docker)       REMOVE_DOCKER=false ;;
        --no-claude)       REMOVE_CLAUDE=false ;;
        --no-gh)           REMOVE_GH=false ;;
        --no-ohmyzsh)      REMOVE_OHMYZSH=false ;;
        --no-zellij)       REMOVE_ZELLIJ=false ;;
        --no-swap)         REMOVE_SWAP=false ;;
        --no-sysctl)       REMOVE_SYSCTL=false ;;
        --no-auto-updates) REMOVE_AUTO_UPDATES=false ;;
        --no-journald)     REMOVE_JOURNALD=false ;;
        --only-base)         ONLY_MODE=true; REMOVE_BASE=true ;;
        --only-firewall)     ONLY_MODE=true; REMOVE_FIREWALL=true ;;
        --only-ssh-harden)   ONLY_MODE=true; REMOVE_SSH_HARDEN=true ;;
        --only-docker)       ONLY_MODE=true; REMOVE_DOCKER=true ;;
        --only-claude)       ONLY_MODE=true; REMOVE_CLAUDE=true ;;
        --only-gh)           ONLY_MODE=true; REMOVE_GH=true ;;
        --only-ohmyzsh)      ONLY_MODE=true; REMOVE_OHMYZSH=true ;;
        --only-zellij)       ONLY_MODE=true; REMOVE_ZELLIJ=true ;;
        --only-swap)         ONLY_MODE=true; REMOVE_SWAP=true ;;
        --only-sysctl)       ONLY_MODE=true; REMOVE_SYSCTL=true ;;
        --only-auto-updates) ONLY_MODE=true; REMOVE_AUTO_UPDATES=true ;;
        --only-journald)     ONLY_MODE=true; REMOVE_JOURNALD=true ;;
        --force|-f)        FORCE=true ;;
        --help|-h)
            echo "Usage: uninstall.sh [OPTIONS]"
            echo ""
            echo "Removes packages and configs installed by setup.sh."
            echo ""
            echo "Skip flags (exclude modules from removal):"
            echo "  --no-base        Keep base packages (htop, tmux, vim, jq)"
            echo "  --no-firewall    Keep UFW firewall"
            echo "  --no-ssh-harden  Keep fail2ban and SSH hardening"
            echo "  --no-docker      Keep Docker"
            echo "  --no-claude      Keep Claude Code"
            echo "  --no-gh          Keep gh/glab CLI"
            echo "  --no-ohmyzsh     Keep Oh My Zsh"
            echo "  --no-zellij      Keep Zellij"
            echo "  --no-swap        Keep swap file"
            echo "  --no-sysctl      Keep kernel tuning"
            echo "  --no-auto-updates Keep unattended upgrades"
            echo "  --no-journald    Keep journald limits"
            echo ""
            echo "Only flags (remove specific modules only):"
            echo "  --only-base, --only-firewall, --only-ssh-harden,"
            echo "  --only-docker, --only-claude, --only-gh, --only-ohmyzsh,"
            echo "  --only-zellij, --only-swap, --only-sysctl,"
            echo "  --only-auto-updates, --only-journald"
            echo ""
            echo "Other:"
            echo "  -f, --force      Skip confirmation prompt"
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

# In --only mode, disable everything first, then re-enable only what was selected
if [[ "$ONLY_MODE" == true ]]; then
    # Save selected values
    SAVE_BASE=$REMOVE_BASE SAVE_FIREWALL=$REMOVE_FIREWALL
    SAVE_SSH=$REMOVE_SSH_HARDEN SAVE_DOCKER=$REMOVE_DOCKER
    SAVE_CLAUDE=$REMOVE_CLAUDE SAVE_GH=$REMOVE_GH
    SAVE_OHMYZSH=$REMOVE_OHMYZSH SAVE_ZELLIJ=$REMOVE_ZELLIJ
    SAVE_SWAP=$REMOVE_SWAP SAVE_SYSCTL=$REMOVE_SYSCTL
    SAVE_UPDATES=$REMOVE_AUTO_UPDATES SAVE_JOURNALD=$REMOVE_JOURNALD

    # Disable all
    REMOVE_BASE=false REMOVE_FIREWALL=false REMOVE_SSH_HARDEN=false
    REMOVE_DOCKER=false REMOVE_CLAUDE=false REMOVE_GH=false
    REMOVE_OHMYZSH=false REMOVE_ZELLIJ=false REMOVE_SWAP=false
    REMOVE_SYSCTL=false REMOVE_AUTO_UPDATES=false REMOVE_JOURNALD=false

    # Re-enable only selected
    [[ "$SAVE_BASE"     == true ]] && REMOVE_BASE=true
    [[ "$SAVE_FIREWALL" == true ]] && REMOVE_FIREWALL=true
    [[ "$SAVE_SSH"      == true ]] && REMOVE_SSH_HARDEN=true
    [[ "$SAVE_DOCKER"   == true ]] && REMOVE_DOCKER=true
    [[ "$SAVE_CLAUDE"   == true ]] && REMOVE_CLAUDE=true
    [[ "$SAVE_GH"       == true ]] && REMOVE_GH=true
    [[ "$SAVE_OHMYZSH"  == true ]] && REMOVE_OHMYZSH=true
    [[ "$SAVE_ZELLIJ"   == true ]] && REMOVE_ZELLIJ=true
    [[ "$SAVE_SWAP"     == true ]] && REMOVE_SWAP=true
    [[ "$SAVE_SYSCTL"   == true ]] && REMOVE_SYSCTL=true
    [[ "$SAVE_UPDATES"  == true ]] && REMOVE_AUTO_UPDATES=true
    [[ "$SAVE_JOURNALD" == true ]] && REMOVE_JOURNALD=true
fi

# --- Check root ---
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# --- Resolve real user ---
REAL_USER="${SUDO_USER:-root}"
REAL_HOME=$(eval echo "~${REAL_USER}")

# --- Confirmation ---
if [[ "$FORCE" != true ]]; then
    echo ""
    echo -e "${RED}╔══════════════════════════════════════╗${NC}"
    echo -e "${RED}║    Server Uninstall Script           ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════╝${NC}"
    echo ""
    log_warn "This will remove the following components:"
    [[ "$REMOVE_JOURNALD"     == true ]] && echo "  - Journald limits"
    [[ "$REMOVE_AUTO_UPDATES" == true ]] && echo "  - Unattended upgrades"
    [[ "$REMOVE_SYSCTL"       == true ]] && echo "  - Kernel tuning (sysctl)"
    [[ "$REMOVE_SWAP"         == true ]] && echo "  - Swap file (2 GB)"
    [[ "$REMOVE_ZELLIJ"       == true ]] && echo "  - Zellij"
    [[ "$REMOVE_OHMYZSH"      == true ]] && echo "  - Oh My Zsh + zsh"
    [[ "$REMOVE_GH"           == true ]] && echo "  - GitHub CLI (gh) + GitLab CLI (glab)"
    [[ "$REMOVE_CLAUDE"       == true ]] && echo "  - Claude Code + ccstatusline"
    [[ "$REMOVE_DOCKER"       == true ]] && echo "  - Docker"
    [[ "$REMOVE_SSH_HARDEN"   == true ]] && echo "  - SSH hardening (fail2ban)"
    [[ "$REMOVE_FIREWALL"     == true ]] && echo "  - UFW Firewall"
    [[ "$REMOVE_BASE"         == true ]] && echo "  - Base packages (htop, tmux, vim, jq)"
    echo ""
    read -rp "Are you sure? [y/N] " confirm
    if [[ "$confirm" != [yY] ]]; then
        log_info "Aborted."
        exit 0
    fi
fi

export DEBIAN_FRONTEND=noninteractive

# ============================================================
# Remove in reverse order of installation
# ============================================================

# --- 1. Journald Limits ---
if [[ "$REMOVE_JOURNALD" == true ]]; then
    log_info "=== Removing Journald limits ==="
    rm -f /etc/systemd/journald.conf.d/limits.conf
    rmdir /etc/systemd/journald.conf.d 2>/dev/null || true
    systemctl restart systemd-journald
    log_success "Journald limits removed"
    echo ""
fi

# --- 2. Auto Updates ---
if [[ "$REMOVE_AUTO_UPDATES" == true ]]; then
    log_info "=== Removing Unattended Upgrades ==="
    systemctl stop unattended-upgrades 2>/dev/null || true
    systemctl disable unattended-upgrades 2>/dev/null || true
    apt-get purge -y unattended-upgrades apt-listchanges 2>/dev/null || true
    rm -f /etc/apt/apt.conf.d/50unattended-upgrades
    rm -f /etc/apt/apt.conf.d/20auto-upgrades
    log_success "Unattended upgrades removed"
    echo ""
fi

# --- 3. Sysctl Tune ---
if [[ "$REMOVE_SYSCTL" == true ]]; then
    log_info "=== Removing kernel tuning ==="
    rm -f /etc/sysctl.d/99-server-tune.conf
    rm -f /etc/security/limits.d/99-server-tune.conf
    sysctl --system > /dev/null 2>&1
    log_success "Kernel tuning removed (defaults restored)"
    echo ""
fi

# --- 4. Swap ---
if [[ "$REMOVE_SWAP" == true ]]; then
    log_info "=== Removing swap file ==="
    if [[ -f /swapfile ]]; then
        swapoff /swapfile 2>/dev/null || true
        rm -f /swapfile
        sed -i '\|/swapfile|d' /etc/fstab
        log_success "Swap file removed"
    else
        log_warn "No /swapfile found, skipping"
    fi
    echo ""
fi

# --- 5. Zellij ---
if [[ "$REMOVE_ZELLIJ" == true ]]; then
    log_info "=== Removing Zellij ==="
    rm -f /usr/local/bin/zellij
    log_success "Zellij removed"
    echo ""
fi

# --- 6. Oh My Zsh ---
if [[ "$REMOVE_OHMYZSH" == true ]]; then
    log_info "=== Removing Oh My Zsh ==="
    if [[ -d "${REAL_HOME}/.oh-my-zsh" ]]; then
        rm -rf "${REAL_HOME}/.oh-my-zsh"
    fi
    # Restore bash as default shell
    if getent passwd "$REAL_USER" | grep -q zsh; then
        chsh -s /bin/bash "$REAL_USER"
        log_info "Default shell changed back to bash for ${REAL_USER}"
    fi
    apt-get purge -y zsh 2>/dev/null || true
    log_success "Oh My Zsh removed"
    echo ""
fi

# --- 7. GitHub/GitLab CLI ---
if [[ "$REMOVE_GH" == true ]]; then
    log_info "=== Removing GitHub/GitLab CLI ==="
    apt-get purge -y gh 2>/dev/null || true
    rm -f /usr/share/keyrings/githubcli-archive-keyring.gpg
    rm -f /etc/apt/sources.list.d/github-cli.list
    dpkg -r glab 2>/dev/null || true
    log_success "gh and glab removed"
    echo ""
fi

# --- 8. Claude Code ---
if [[ "$REMOVE_CLAUDE" == true ]]; then
    log_info "=== Removing Claude Code ==="
    if command -v npm &>/dev/null; then
        npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
    fi
    rm -rf "${REAL_HOME}/.config/ccstatusline"
    # Remove statusLine key from Claude settings if the file exists
    if [[ -f "${REAL_HOME}/.claude/settings.json" ]] && command -v jq &>/dev/null; then
        TMPFILE=$(mktemp)
        jq 'del(.statusLine)' "${REAL_HOME}/.claude/settings.json" > "$TMPFILE" && \
            mv "$TMPFILE" "${REAL_HOME}/.claude/settings.json"
        chown "${REAL_USER}:${REAL_USER}" "${REAL_HOME}/.claude/settings.json"
    fi
    log_success "Claude Code removed"
    echo ""
fi

# --- 9. Docker ---
if [[ "$REMOVE_DOCKER" == true ]]; then
    log_info "=== Removing Docker ==="
    systemctl stop docker docker.socket containerd 2>/dev/null || true
    systemctl disable docker docker.socket containerd 2>/dev/null || true
    apt-get purge -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
    rm -f /etc/apt/keyrings/docker.asc
    rm -f /etc/apt/sources.list.d/docker.list
    if getent group docker &>/dev/null && [[ -n "$REAL_USER" ]]; then
        gpasswd -d "$REAL_USER" docker 2>/dev/null || true
    fi
    log_success "Docker removed"
    echo ""
fi

# --- 10. SSH Hardening ---
if [[ "$REMOVE_SSH_HARDEN" == true ]]; then
    log_info "=== Removing SSH hardening ==="
    systemctl stop fail2ban 2>/dev/null || true
    systemctl disable fail2ban 2>/dev/null || true
    apt-get purge -y fail2ban 2>/dev/null || true
    rm -f /etc/fail2ban/jail.local
    rm -f /etc/ssh/sshd_config.d/99-keepalive.conf
    if sshd -t 2>/dev/null; then
        systemctl reload sshd 2>/dev/null || true
    fi
    log_success "SSH hardening removed"
    echo ""
fi

# --- 11. Firewall ---
if [[ "$REMOVE_FIREWALL" == true ]]; then
    log_info "=== Removing UFW Firewall ==="
    ufw disable 2>/dev/null || true
    apt-get purge -y ufw 2>/dev/null || true
    log_success "UFW removed"
    echo ""
fi

# --- 12. Base packages ---
if [[ "$REMOVE_BASE" == true ]]; then
    log_info "=== Removing base packages ==="
    # Only remove utility packages; keep curl, wget, git, ca-certificates etc.
    # as they are commonly needed by the system
    apt-get purge -y htop tmux vim jq 2>/dev/null || true
    log_success "Base utility packages removed"
    echo ""
fi

# --- Cleanup ---
log_info "=== Cleaning up ==="
apt-get autoremove -y 2>/dev/null || true
apt-get update 2>/dev/null || true

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      Uninstall complete!             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
log_info "You may need to re-login for shell changes to take effect."
