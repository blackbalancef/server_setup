# Server Setup

Bash-скрипт для быстрой настройки нового Ubuntu/Debian сервера. Одна команда — и сервер готов к работе.

## Что устанавливается

| Модуль | Описание | Флаг отключения |
|--------|----------|-----------------|
| **Base** | `apt update/upgrade`, curl, git, htop, tmux, vim, jq и др. | `--no-base` |
| **Firewall** | UFW: deny incoming, allow outgoing, allow SSH | `--no-firewall` |
| **SSH Hardening** | fail2ban: бан на 1 час после 3 неудачных попыток за 10 мин | `--no-ssh-harden` |
| **Docker** | Docker CE + Compose + Buildx из официального репозитория | `--no-docker` |
| **Claude Code** | Node.js LTS + Claude Code CLI | `--no-claude` |
| **gh / glab** | GitHub CLI и GitLab CLI | `--no-gh` |
| **Oh My Zsh** | Zsh + Oh My Zsh для текущего пользователя | `--no-ohmyzsh` |

## Быстрый старт

```bash
curl -fsSL https://raw.githubusercontent.com/blackbalancef/server_setup/main/setup.sh | sudo bash
```

## Выборочная установка

```bash
# Без Docker и Claude
curl -fsSL https://raw.githubusercontent.com/blackbalancef/server_setup/main/setup.sh | sudo bash -s -- --no-docker --no-claude

# Только базовые пакеты и firewall
curl -fsSL https://raw.githubusercontent.com/blackbalancef/server_setup/main/setup.sh | sudo bash -s -- --no-ssh-harden --no-docker --no-claude --no-gh --no-ohmyzsh
```

## Требования

- Ubuntu или Debian
- Root-доступ (sudo)
- Доступ в интернет

## Структура

```
setup.sh              # Точка входа
modules/
  base.sh             # Базовые пакеты
  firewall.sh         # UFW
  ssh_harden.sh       # fail2ban
  docker.sh           # Docker CE
  claude.sh           # Claude Code
  gh_glab.sh          # gh + glab
  ohmyzsh.sh          # Oh My Zsh
```
