# Server Setup

One-command setup script for a fresh Ubuntu/Debian server.

## What gets installed

| Module | Description | Disable flag |
|--------|-------------|--------------|
| **Base** | `apt update/upgrade`, curl, git, htop, tmux, vim, jq, etc. | `--no-base` |
| **Firewall** | UFW: deny incoming, allow outgoing, allow SSH | `--no-firewall` |
| **SSH Hardening** | fail2ban + SSH keepalive for stable connections | `--no-ssh-harden` |
| **Docker** | Docker CE + Compose + Buildx from the official repository | `--no-docker` |
| **Claude Code** | Node.js LTS + Claude Code CLI + ccstatusline | `--no-claude` |
| **gh / glab** | GitHub CLI and GitLab CLI | `--no-gh` |
| **Oh My Zsh** | Zsh + Oh My Zsh for the current user | `--no-ohmyzsh` |
| **Zellij** | Zellij terminal multiplexer | `--no-zellij` |
| **Swap** | 2 GB swap file (OOM protection) | `--no-swap` |
| **Kernel Tuning** | sysctl: network buffers, BBR, file limits, swappiness | `--no-sysctl` |
| **Auto Updates** | Unattended security upgrades | `--no-auto-updates` |
| **Journald Limits** | Log rotation: 500 MB max, 30-day retention | `--no-journald` |

## Module details

### Base

Updates the system and installs essential CLI tools: `curl`, `wget`, `git`, `unzip`, `htop`, `tmux`, `vim`, `jq`, and others. This is the foundation — without these packages the rest of the modules and day-to-day server work won't function properly.

### Firewall (UFW)

Sets up UFW with a sane default policy: deny all incoming traffic, allow all outgoing, explicitly allow SSH (port 22). Protects from unwanted connections out of the box without breaking remote access.

### SSH Hardening (fail2ban + keepalive)

Installs fail2ban to protect SSH from brute-force attacks. Configuration: 3 failed login attempts within 10 minutes = 1-hour IP ban. Dramatically reduces the noise from automated bots and the chance of a successful brute-force.

Also configures SSH keepalive for stable connections:

- **`ClientAliveInterval 60`** — server pings the client every 60 seconds
- **`ClientAliveCountMax 3`** — drops the session after 3 missed replies (~3 min of silence)
- **`TCPKeepAlive no`** — disables OS-level TCP keepalive in favor of SSH-level keepalive, which is more reliable through NATs and firewalls
- **`MaxSessions 10`** — allows up to 10 multiplexed sessions per connection

This prevents the common "broken pipe" / "connection reset" issues when working over unstable networks or leaving sessions idle.

### Docker

Installs Docker CE, Docker Compose, and Buildx from the official Docker repository. Removes any pre-existing unofficial Docker packages to avoid conflicts. Adds the current user to the `docker` group so containers can be managed without `sudo`.

### Claude Code

Installs Node.js LTS and the Claude Code CLI (`@anthropic-ai/claude-code`) globally via npm. Also sets up ccstatusline for terminal status integration. Gives you an AI coding assistant directly in the server terminal.

### gh / glab

Installs GitHub CLI (`gh`) and GitLab CLI (`glab`) so you can manage PRs, issues, and CI/CD pipelines without leaving the terminal.

### Oh My Zsh

Installs Zsh and the Oh My Zsh framework. Switches the default shell to Zsh for the current user. Provides autocompletion, syntax highlighting themes, and a more productive shell experience.

### Zellij

Installs the Zellij terminal multiplexer. A modern alternative to tmux with a built-in layout system and a discoverable UI. Useful for running multiple terminal panes within a single SSH session.

### Swap

Creates a 2 GB swap file and persists it via `/etc/fstab`. Swap acts as an emergency overflow when physical RAM runs out — instead of the OOM killer terminating your processes, the system pages memory to disk. Essential for small VPS instances (1–2 GB RAM) where Docker or Node.js can easily spike memory usage.

### Kernel Tuning (sysctl)

Applies production-grade kernel parameters via `/etc/sysctl.d/`:

- **`vm.swappiness = 10`** — prefer keeping data in RAM, only swap under real pressure
- **TCP BBR** — modern congestion control algorithm, significantly better throughput on lossy networks
- **Network buffers up to 16 MB** — handles high-throughput workloads without dropping packets
- **`somaxconn = 65535`** — large connection backlog for web servers and reverse proxies
- **`fs.file-max = 2M`** + raised ulimits — prevents "too many open files" errors under load
- **ICMP redirect disabled** — hardens against MITM routing attacks

### Auto Updates (unattended-upgrades)

Enables automatic installation of security patches from official repositories. Only security updates are applied — no surprise major version bumps. Automatic reboot is disabled, so the server stays online. Keeps the system patched against known vulnerabilities without manual intervention.

### Journald Limits

Caps systemd journal storage at 500 MB with a 30-day retention period and compression enabled. Without this, logs can quietly grow to fill the entire disk over months, eventually causing service failures. This module prevents that while keeping enough history for debugging.

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

## Resource usage

| Module | Disk space | RAM (daemon / idle) |
|--------|-----------|---------------------|
| **Base** | ~150–200 MB | — |
| **Firewall** | ~10 MB | — |
| **SSH Hardening** | ~5–10 MB | ~20–50 MB (fail2ban) |
| **Docker** | ~500–800 MB | ~100–300 MB (dockerd) |
| **Claude Code** | ~300–400 MB | on demand |
| **gh / glab** | ~30–50 MB | — |
| **Oh My Zsh** | ~20–50 MB | — |
| **Zellij** | ~10–20 MB | ~30–80 MB per session |
| **Swap** | 2 GB (swap file) | — (extends effective RAM) |
| **Kernel Tuning** | < 1 MB (config) | — |
| **Auto Updates** | ~5–10 MB | — |
| **Journald Limits** | < 1 MB (config) | — (saves up to GBs of logs) |

**Full install totals:** ~1.0–1.5 GB disk + 2 GB swap, ~200–500 MB RAM with all daemons running.

The heaviest modules are **Docker** and **Claude Code** (Node.js). Use `--no-docker` / `--no-claude` to skip them on lightweight machines.

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
  zellij.sh           # Zellij
  swap.sh             # Swap file
  sysctl_tune.sh      # Kernel tuning
  auto_updates.sh     # Unattended upgrades
  journald.sh         # Journald log limits
```
