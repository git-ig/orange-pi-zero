#!/usr/bin/env bash
set -Eeuo pipefail

ZRAM_ALGO="${ZRAM_ALGO:-zstd}"
ZRAM_SIZE_MIB="${ZRAM_SIZE_MIB:-1950}"
ZRAM_PERCENT="${ZRAM_PERCENT:-}"
ZRAM_PRIORITY="${ZRAM_PRIORITY:-100}"
SWAPPINESS="${SWAPPINESS:-100}"
VFS_CACHE_PRESSURE="${VFS_CACHE_PRESSURE:-50}"

ROOT_CMD=()

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

require_dietpi() {
  [[ -d /boot/dietpi ]] || die "This script is intended for DietPi."
}

install_packages() {
  log "Installing zram package"
  run_root env DEBIAN_FRONTEND=noninteractive apt-get update
  run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends zram-tools
}

disable_disk_swap() {
  local swap_target

  log "Disabling disk-backed swap"

  for swap_target in /var/swap /swapfile; do
    if swapon --noheadings --show=NAME 2>/dev/null | grep -Fxq "$swap_target"; then
      run_root swapoff "$swap_target"
    fi
  done

  if systemctl list-unit-files dphys-swapfile.service >/dev/null 2>&1; then
    run_root systemctl disable --now dphys-swapfile || true
  fi

  if [[ -f /etc/dphys-swapfile ]]; then
    run_root tee /etc/dphys-swapfile >/dev/null <<'EOF'
CONF_SWAPFILE=/var/swap
CONF_SWAPSIZE=0
EOF
  fi

  run_root sed -i '\|^/swapfile[[:space:]]\+none[[:space:]]\+swap|d' /etc/fstab
  run_root sed -i '\|^/var/swap[[:space:]]\+none[[:space:]]\+swap|d' /etc/fstab
  run_root rm -f /swapfile /var/swap
}

configure_zram() {
  log "Configuring zram-tools"

  if [[ -n "$ZRAM_SIZE_MIB" ]]; then
    run_root tee /etc/default/zramswap >/dev/null <<EOF
ALGO=${ZRAM_ALGO}
SIZE=${ZRAM_SIZE_MIB}
PRIORITY=${ZRAM_PRIORITY}
EOF
  elif [[ -n "$ZRAM_PERCENT" ]]; then
    run_root tee /etc/default/zramswap >/dev/null <<EOF
ALGO=${ZRAM_ALGO}
PERCENT=${ZRAM_PERCENT}
PRIORITY=${ZRAM_PRIORITY}
EOF
  else
    die "Set either ZRAM_SIZE_MIB or ZRAM_PERCENT."
  fi

  if ! run_root modprobe zram; then
    warn "modprobe zram failed. zramswap service may still work if zram is built into the kernel."
  fi

  run_root systemctl enable zramswap
  run_root systemctl restart zramswap
}

configure_sysctl() {
  log "Configuring swappiness"

  run_root tee /etc/sysctl.d/99-swap.conf >/dev/null <<EOF
vm.swappiness=${SWAPPINESS}
vm.vfs_cache_pressure=${VFS_CACHE_PRESSURE}
EOF

  run_root sysctl --system >/dev/null
}

verify_setup() {
  log "Verifying swap and zram"
  swapon --show
  zramctl || true
  free -h
}

print_summary() {
  log "Done"
  printf 'Disk swap: disabled\n'

  if [[ -n "$ZRAM_SIZE_MIB" ]]; then
    printf 'zRAM size: %s MiB\n' "$ZRAM_SIZE_MIB"
  else
    printf 'zRAM size: %s%% of RAM\n' "$ZRAM_PERCENT"
  fi
}

main() {
  setup_privileges
  require_dietpi
  install_packages
  disable_disk_swap
  configure_zram
  configure_sysctl
  verify_setup
  print_summary
}

main "$@"
