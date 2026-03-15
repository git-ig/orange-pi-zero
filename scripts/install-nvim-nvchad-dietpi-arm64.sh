#!/usr/bin/env bash
set -euo pipefail

echo "[1/9] Installing dependencies..."
sudo apt update
sudo apt install -y git make gcc ripgrep fd-find unzip xclip curl

echo "[2/9] Installing Neovim ARM64..."
cd "$HOME"
rm -f nvim-linux-x86_64.tar.gz nvim-linux-arm64.tar.gz
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz

sudo rm -rf /opt/nvim
sudo mkdir -p /opt/nvim
sudo tar -C /opt/nvim --strip-components=1 -xzf nvim-linux-arm64.tar.gz
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

echo "[3/9] Fixing fd binary name on Debian..."
if command -v fdfind >/dev/null 2>&1; then
  sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
fi

echo "[4/9] Cleaning old Neovim config/state..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim ~/.local/state/nvim

echo "[5/9] Cloning NvChad starter..."
git clone https://github.com/NvChad/starter ~/.config/nvim --depth 1

echo "[6/9] Patching init.lua for better compatibility..."
cat > ~/.config/nvim/init.lua <<'LUA'
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

local uv = vim.uv or vim.loop

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (uv and uv.fs_stat and uv.fs_stat(lazypath)) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(lazypath)

local ok_lazycfg, lazy_config = pcall(require, "configs.lazy")
if not ok_lazycfg then
  lazy_config = {}
end

local ok_lazy, lazy = pcall(require, "lazy")
if not ok_lazy then
  vim.api.nvim_err_writeln("lazy.nvim failed to load")
  return
end

lazy.setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  { import = "plugins" },
}, lazy_config)

pcall(dofile, vim.g.base46_cache .. "defaults")
pcall(dofile, vim.g.base46_cache .. "statusline")

pcall(require, "options")
pcall(require, "autocmds")

vim.schedule(function()
  pcall(require, "mappings")
end)
LUA

echo "[7/9] Checking Neovim version..."
hash -r
nvim --version | head -n 3

echo "[8/9] First start bootstrap..."
nvim --headless "+q" || true

echo "[9/9] Done."
echo
echo "Now run:"
echo "  nvim"
