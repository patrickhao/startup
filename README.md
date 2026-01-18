# Linux Development Environment Setup

Automated setup script for a modern Linux development environment.

## Prerequisites

- Ubuntu/Debian-based Linux (x86_64)
- sudo access
- Internet connection
- 2GB+ free disk space

## Installation

```bash
git clone <repository-url>
cd startup
bash run.sh
source ~/.zshrc
```

## What Gets Installed

**System Packages**: vim, neovim, zsh, tmux, build-essential, git, python3, python3-pip, python3-venv, fzf, ripgrep, luarocks

**Oh My Zsh Plugins**: zsh-autosuggestions, zsh-syntax-highlighting, zsh-vi-mode

**Additional Tools**: fd (v10.2.0), LazyVim, lazygit (v0.49.0), Go (1.24.2)

**Configurations**: Tmux (Catppuccin theme), Neovim (LazyVim), Zsh

## Post-Installation

**Tmux**: Launch tmux and press `Ctrl-F + I` to install plugins

**Neovim**: Launch `nvim` (plugins auto-install), then:
- Install Treesitter parsers: `:TSInstall <language>`
- Install LSP servers: `<space> c m`

## Configuration

Edit version variables in `run.sh`:
```bash
readonly FD_VERSION="v10.2.0"
readonly LAZYGIT_VERSION="v0.49.0"
readonly GO_VERSION="go1.24.2"
```

Customize configs before running:
- Zsh: `zsh/.zshrc`
- Tmux: `tmux/.tmux.conf`
- Neovim: `nvim/config/` and `nvim/plugins/`

## Troubleshooting

**Shell not changed**: `chsh -s $(which zsh)` then re-login

**Tmux plugins not loading**: Press `Ctrl-F + I` inside tmux

**PATH not updated**: `source ~/.zshrc` or restart terminal

**Script is safe to re-run** - it's idempotent and will clean up before reinstalling.

## Uninstallation

```bash
rm -rf ~/.oh-my-zsh ~/.tmux/plugins ~/.config/nvim ~/softwares ~/.zshrc ~/.tmux.conf
chsh -s $(which bash)
```
