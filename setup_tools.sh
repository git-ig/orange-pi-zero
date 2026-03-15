#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_CMD=()
APT_UPDATED=0

log() {
  printf '\n==> %s\n' "$1"
}

warn() {
  printf 'Warning: %s\n' "$1" >&2
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

on_error() {
  local line_number="$1"
  printf 'Error: %s failed at line %s\n' "${0##*/}" "$line_number" >&2
  exit 1
}

trap 'on_error $LINENO' ERR

run_root() {
  "${ROOT_CMD[@]}" "$@"
}

setup_privileges() {
  if (( EUID == 0 )); then
    ROOT_CMD=()
    return
  fi

  command -v sudo >/dev/null 2>&1 || die "sudo is required when running as a regular user."
  ROOT_CMD=(sudo)
}

require_target_host() {
  local arch
  local board_model

  arch="$(dpkg --print-architecture 2>/dev/null || uname -m)"
  case "$arch" in
    arm64|aarch64) ;;
    *) die "This script is intended for DietPi on ARM64. Detected architecture: $arch" ;;
  esac

  [[ -d /boot/dietpi ]] || die "This host does not look like DietPi."

  if [[ -r /sys/firmware/devicetree/base/model ]]; then
    board_model="$(tr -d '\0' < /sys/firmware/devicetree/base/model)"
    log "Detected board: $board_model"

    if [[ "$board_model" != *"Orange Pi Zero 2W"* ]]; then
      warn "Board model does not match Orange Pi Zero 2W exactly. Continuing anyway."
    fi
  fi
}

apt_update() {
  if (( APT_UPDATED == 0 )); then
    log "Refreshing APT package index"
    run_root env DEBIAN_FRONTEND=noninteractive apt-get update
    APT_UPDATED=1
  fi
}

package_available() {
  apt-cache show "$1" >/dev/null 2>&1
}

install_required_packages() {
  local packages=(
    bash-completion
    build-essential
    ca-certificates
    curl
    fd-find
    fzf
    git
    htop
    jq
    neovim
    ripgrep
    rsync
    tmux
    tree
    unzip
    wget
  )
  local missing=()
  local package

  for package in "${packages[@]}"; do
    if ! package_available "$package"; then
      missing+=("$package")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    die "Required packages are missing from APT: ${missing[*]}"
  fi

  log "Installing required packages"
  run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"
}

install_optional_packages() {
  local packages=(
    bat
    btop
    duf
    gdu
    ncdu
    zoxide
  )
  local available=()
  local skipped=()
  local package

  for package in "${packages[@]}"; do
    if package_available "$package"; then
      available+=("$package")
    else
      skipped+=("$package")
    fi
  done

  if (( ${#available[@]} > 0 )); then
    log "Installing optional packages available in current DietPi repositories"
    run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${available[@]}"
  fi

  if (( ${#skipped[@]} > 0 )); then
    warn "Skipping optional packages not available via APT: ${skipped[*]}"
  fi
}

cleanup_legacy_neovim() {
  local target

  if [[ -L /usr/local/bin/nvim ]]; then
    target="$(readlink /usr/local/bin/nvim || true)"
    if [[ "$target" == "/opt/nvim/bin/nvim" ]]; then
      log "Removing legacy /opt/nvim Neovim symlink"
      run_root rm -f /usr/local/bin/nvim
    fi
  fi

  if [[ -d /opt/nvim ]]; then
    warn "Legacy /opt/nvim directory detected. It was left untouched on purpose."
  fi
}

ensure_fd_command() {
  if command -v fd >/dev/null 2>&1; then
    return
  fi

  if command -v fdfind >/dev/null 2>&1; then
    log "Creating fd shim for Debian's fdfind package"
    run_root install -d /usr/local/bin
    run_root ln -sf /usr/bin/fdfind /usr/local/bin/fd
  fi
}

configure_shell() {
  local shell_rc="$HOME/.bashrc"
  local shell_addons="$HOME/.bash_aliases.orange-pi-zero"
  local source_line='[ -f "$HOME/.bash_aliases.orange-pi-zero" ] && . "$HOME/.bash_aliases.orange-pi-zero"'

  log "Writing Orange Pi shell profile"

  cat > "$shell_addons" <<'EOF'
# Managed by orange-pi-zero/setup_tools.sh

if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
  export VISUAL="nvim"
  alias vi="nvim"
  alias vim="nvim"
fi

if command -v batcat >/dev/null 2>&1; then
  alias bat="batcat"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

alias ll='ls -alF --group-directories-first'
alias la='ls -A'
alias l='ls -CF'

if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
fi

export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
EOF

  touch "$shell_rc"
  grep -qxF "$source_line" "$shell_rc" || printf '\n%s\n' "$source_line" >> "$shell_rc"
}

print_summary() {
  log "Done"
  printf 'Run: source %s\n' "$HOME/.bashrc"
  printf 'Check: nvim --version\n'
}

main() {
  setup_privileges
  require_target_host
  apt_update
  install_required_packages
  install_optional_packages
  cleanup_legacy_neovim
  ensure_fd_command
  configure_shell
  print_summary
}

main "$@"
