# orange-pi-zero

Setup repo for a single target host: Orange Pi Zero 2W running DietPi ARM64.

## What is here

- `setup_tools.sh` installs a stable base CLI/tooling set from DietPi/Debian repositories.
- The script intentionally avoids `curl | sh`, third-party APT repositories, and destructive Neovim/NvChad bootstrapping.

## Run

```bash
chmod +x ./setup_tools.sh
./setup_tools.sh
```

## Notes

- The script expects DietPi on ARM64.
- If it finds an old `/opt/nvim` install from previous experiments, it leaves that directory in place and only removes the legacy `/usr/local/bin/nvim` symlink when needed.
- Shell tweaks are written to `~/.bash_aliases.orange-pi-zero` and sourced from `~/.bashrc`.
