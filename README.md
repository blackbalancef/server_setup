# Server Setup

One-command setup script for a fresh Ubuntu/Debian server.

## What gets installed

| Module | Description | Disable flag |
|--------|-------------|--------------|
| **Base** | `apt update/upgrade`, curl, git, htop, tmux, vim, jq, etc. | `--no-base` |
| **Firewall** | UFW: deny incoming, allow outgoing, allow SSH | `--no-firewall` |
| **SSH Hardening** | fail2ban: 1-hour ban after 3 failed attempts within 10 min | `--no-ssh-harden` |
| **Docker** | Docker CE + Compose + Buildx from the official repository | `--no-docker` |
| **Claude Code** | Node.js LTS + Claude Code CLI + ccstatusline | `--no-claude` |
| **gh / glab** | GitHub CLI and GitLab CLI | `--no-gh` |
| **Oh My Zsh** | Zsh + Oh My Zsh for the current user | `--no-ohmyzsh` |

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/blackbalancef/server_setup/main/setup.sh | sudo bash
```

## Selective install

```bash
# Skip Docker and Claude
curl -fsSL https://raw.githubusercontent.com/blackbalancef/server_setup/main/setup.sh | sudo bash -s -- --no-docker --no-claude

# Only base packages and firewall
curl -fsSL https://raw.githubusercontent.com/blackbalancef/server_setup/main/setup.sh | sudo bash -s -- --no-ssh-harden --no-docker --no-claude --no-gh --no-ohmyzsh
```

## Requirements

- Ubuntu or Debian
- Root access (sudo)
- Internet connection

## Structure

```
setup.sh              # Entry point
modules/
  base.sh             # Base packages
  firewall.sh         # UFW
  ssh_harden.sh       # fail2ban
  docker.sh           # Docker CE
  claude.sh           # Claude Code + ccstatusline
  gh_glab.sh          # gh + glab
  ohmyzsh.sh          # Oh My Zsh
```
