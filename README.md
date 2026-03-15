# Orange Pi Zero 2W + DietPi

This repository is a clean setup base for one specific machine:

- board: Orange Pi Zero 2W
- OS: DietPi ARM64
- access: Tailscale-only services via `TAILSCALE_IP` from `.env`

The goal is simple: keep the machine predictable, lightweight and easy to restore.

## Quick Start

Clone the repo and run the setup script:

```bash
git clone https://github.com/git-ig/orange-pi-zero.git
cd orange-pi-zero
cp .env.example .env
chmod +x ./scripts/setup_tools.sh
./scripts/setup_tools.sh
source ~/.bashrc
```

Raw install link for the script:

[scripts/setup_tools.sh](https://raw.githubusercontent.com/git-ig/orange-pi-zero/main/scripts/setup_tools.sh)

## What `scripts/setup_tools.sh` Does

The script in [scripts/setup_tools.sh](/Users/imb1/dev/orange-pi-zero/scripts/setup_tools.sh#L1):

- verifies that the host is DietPi on ARM64
- checks the board model and warns if it is not exactly Orange Pi Zero 2W
- installs a stable CLI toolset from DietPi/Debian repositories only
- avoids third-party APT repos and avoids `curl | sh`
- installs Neovim from APT instead of custom tarballs
- creates a Debian-friendly `fd` shim for `fdfind`
- writes shell tweaks into `~/.bash_aliases.orange-pi-zero`

## Extra Scripts

- `scripts/configure-zram-dietpi.sh` disables disk-backed swap on DietPi and enables `zram-tools` with sysctl tuning.

## Installed Tooling

Required packages:

- `bash-completion`
- `build-essential`
- `ca-certificates`
- `curl`
- `fd-find`
- `fzf`
- `git`
- `htop`
- `jq`
- `lazydocker`
- `neovim`
- `ripgrep`
- `rsync`
- `tmux`
- `tree`
- `unzip`
- `wget`

Optional packages are installed only if they exist in the current DietPi/Debian repository set:

- `bat`
- `btop`
- `duf`
- `gdu`
- `ncdu`
- `zoxide`

## Shell Profile

The script writes a managed shell profile to `~/.bash_aliases.orange-pi-zero` and auto-sources it from `~/.bashrc`.

Current aliases and shell helpers:

- `vi` and `vim` -> `nvim`
- `bat` -> `batcat` if `batcat` exists
- `lzd` -> `lazydocker`
- `ll`, `la`, `l`
- `zoxide` init if installed
- `fzf` defaults powered by `rg`

`lazydocker` is installed from the official ARM64 GitHub release with a pinned version and `sha256` verification.

## Docker Services

All app UIs are bound only to the Tailscale IP from `.env`.

Example `.env`:

```env
TAILSCALE_IP=100.64.79.123
```

| Service | Path | URL |
| --- | --- | --- |
| Homepage dashboard | `docks/dashboards` | `http://TAILSCALE_IP:4004` |
| File Browser | `docks/filebrowser` | `http://TAILSCALE_IP:4005` |
| Gitea | `docks/gitea` | `http://TAILSCALE_IP:4044` |
| Gitea SSH | `docks/gitea` | `ssh://git@TAILSCALE_IP:4022` |
| Beszel Hub | `docks/beszel` | `http://TAILSCALE_IP:4046` |

## Start Services

Examples:

```bash
docker compose --env-file .env -f docks/dashboards/docker-compose.yml up -d
docker compose --env-file .env -f docks/filebrowser/docker-compose.yml up -d
docker compose --env-file .env -f docks/gitea/docker-compose.yml up -d
docker compose --env-file .env -f docks/beszel/docker-compose.yml up -d
```

Beszel agent is optional and sits behind a Compose profile:

```bash
docker compose --env-file .env -f docks/beszel/docker-compose.yml --profile agent up -d
```

Before starting the agent, replace the placeholder `TOKEN` and `KEY` in [docks/beszel/docker-compose.yml](/Users/imb1/dev/orange-pi-zero/docks/beszel/docker-compose.yml#L1).

## Repo Layout

```text
.
├── scripts
│   ├── configure-zram-dietpi.sh
│   └── setup_tools.sh
├── docks
│   ├── dashboard
│   ├── filebrowser
│   ├── gitea
│   └── beszel
└── README.md
```

## Notes

- The script does not wipe your Neovim config.
- If an old `/opt/nvim` install exists, it is left in place.
- Compose files were validated with `docker compose config`.
- `scripts/configure-zram-dietpi.sh` is `zRAM-only`: disk swap is disabled on purpose to reduce SD card or flash wear.
