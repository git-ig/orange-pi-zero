# Orange Pi Zero 2W + DietPi

This repository is a clean setup base for one specific machine:

- board: Orange Pi Zero 2W
- OS: DietPi ARM64
- access: Tailscale-only services on `100.64.79.123`

The goal is simple: keep the machine predictable, lightweight and easy to restore.

## Quick Start

Clone the repo and run the setup script:

```bash
git clone https://github.com/git-ig/orange-pi-zero.git
cd orange-pi-zero
chmod +x ./setup_tools.sh
./setup_tools.sh
source ~/.bashrc
```

Raw install link for the script:

[setup_tools.sh](https://raw.githubusercontent.com/git-ig/orange-pi-zero/main/setup_tools.sh)

## What `setup_tools.sh` Does

The script in [setup_tools.sh](/Users/imb1/dev/orange-pi-zero/setup_tools.sh#L1):

- verifies that the host is DietPi on ARM64
- checks the board model and warns if it is not exactly Orange Pi Zero 2W
- installs a stable CLI toolset from DietPi/Debian repositories only
- avoids third-party APT repos and avoids `curl | sh`
- installs Neovim from APT instead of custom tarballs
- creates a Debian-friendly `fd` shim for `fdfind`
- writes shell tweaks into `~/.bash_aliases.orange-pi-zero`

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

All app UIs are bound only to the Tailscale IP `100.64.79.123`.

| Service | Path | URL |
| --- | --- | --- |
| Homepage dashboard | `docks/dashboards` | `http://100.64.79.123:4004` |
| File Browser | `docks/filebrowser` | `http://100.64.79.123:4005` |
| Gitea | `docks/gitea` | `http://100.64.79.123:4044` |
| Gitea SSH | `docks/gitea` | `ssh://git@100.64.79.123:4022` |
| Beszel Hub | `docks/beszel` | `http://100.64.79.123:4046` |

## Start Services

Examples:

```bash
cd docks/dashboards && docker compose up -d
cd docks/filebrowser && docker compose up -d
cd docks/gitea && docker compose up -d
cd docks/beszel && docker compose up -d
```

Beszel agent is optional and sits behind a Compose profile:

```bash
cd docks/beszel
docker compose --profile agent up -d
```

Before starting the agent, replace the placeholder `TOKEN` and `KEY` in [docks/beszel/docker-compose.yml](/Users/imb1/dev/orange-pi-zero/docks/beszel/docker-compose.yml#L1).

## Repo Layout

```text
.
├── setup_tools.sh
├── docks
│   ├── dashboards
│   ├── filebrowser
│   ├── gitea
│   └── beszel
└── README.md
```

## Notes

- The script does not wipe your Neovim config.
- If an old `/opt/nvim` install exists, it is left in place.
- Compose files were validated with `docker compose config`.
