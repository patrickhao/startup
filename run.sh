#!/bin/bash

# Strict error handling
set -e          # Exit on error
set -u          # Exit on undefined variable
set -o pipefail # Exit on pipe failure

# ============================================================================
# Configuration Variables
# ============================================================================

# Version configuration
readonly FD_VERSION="v10.2.0"
readonly LAZYGIT_VERSION="v0.49.0"
readonly GO_VERSION="go1.24.2"

# Directory configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOFTWARES_DIR="${HOME}/softwares"

# Color codes for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_BLUE='\033[0;34m'

# ============================================================================
# Utility Functions
# ============================================================================

# Log functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

# Error handler
error_handler() {
    local line_num=$1
    log_error "Script failed at line ${line_num}"
    log_error "Installation incomplete. Please check the error messages above."
    exit 1
}

# Set up error trap
trap 'error_handler ${LINENO}' ERR

# Safe directory removal
safe_remove() {
    local dir="$1"
    if [[ -n "${dir}" && -e "${dir}" ]]; then
        log_info "Removing existing directory: ${dir}"
        rm -rf "${dir}"
    fi
}

# Add path to zshrc if not already present
add_to_path() {
    local path_to_add="$1"
    local zshrc="${HOME}/.zshrc"
    local export_line="export PATH=\$PATH:${path_to_add}"

    if ! grep -qF "${path_to_add}" "${zshrc}" 2>/dev/null; then
        echo "${export_line}" >> "${zshrc}"
        log_info "Added ${path_to_add} to PATH"
    else
        log_info "Path ${path_to_add} already in .zshrc"
    fi
}

# Download and extract tarball
download_and_extract() {
    local url="$1"
    local extract_dir="$2"
    local filename
    filename="$(basename "${url}")"

    log_info "Downloading ${filename}..."
    if ! curl -fsSL -O "${url}"; then
        log_error "Failed to download ${url}"
        return 1
    fi

    log_info "Extracting ${filename}..."
    if ! tar -C "${extract_dir}" -xzf "${filename}"; then
        log_error "Failed to extract ${filename}"
        return 1
    fi

    rm -f "${filename}"
    log_success "Downloaded and extracted ${filename}"
}

# Clone git repository
clone_repo() {
    local repo_url="$1"
    local target_dir="$2"

    safe_remove "${target_dir}"

    log_info "Cloning ${repo_url}..."
    if ! git clone --depth 1 "${repo_url}" "${target_dir}"; then
        log_error "Failed to clone ${repo_url}"
        return 1
    fi

    log_success "Cloned ${repo_url}"
}

# ============================================================================
# Installation Functions
# ============================================================================

install_system_packages() {
    log_info "Installing system packages..."

    if ! sudo apt update; then
        log_error "Failed to update package list"
        return 1
    fi

    local packages=(
        vim curl wget git zsh tmux
        build-essential python3 python3-pip python3-venv
        fzf ripgrep luarocks
    )

    if ! sudo apt install -y "${packages[@]}"; then
        log_error "Failed to install system packages"
        return 1
    fi

    log_success "System packages installed"
}

install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."

    clone_repo "https://github.com/ohmyzsh/ohmyzsh.git" "${HOME}/.oh-my-zsh"

    # Copy zshrc configuration
    if ! cp "${SCRIPT_DIR}/zsh/.zshrc" "${HOME}/.zshrc"; then
        log_error "Failed to copy .zshrc"
        return 1
    fi

    # Change default shell to zsh
    log_info "Changing default shell to zsh..."
    if ! chsh -s "$(which zsh)"; then
        log_warning "Failed to change default shell. You may need to run: chsh -s \$(which zsh)"
    fi

    # Install zsh plugins
    local plugins_dir="${HOME}/.oh-my-zsh/custom/plugins"

    clone_repo "https://github.com/zsh-users/zsh-autosuggestions" \
        "${plugins_dir}/zsh-autosuggestions"

    clone_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
        "${plugins_dir}/zsh-syntax-highlighting"

    clone_repo "https://github.com/jeffreytse/zsh-vi-mode" \
        "${plugins_dir}/zsh-vi-mode"

    log_success "Oh My Zsh installed"
}

install_tmux() {
    log_info "Installing Tmux configuration..."

    clone_repo "https://github.com/tmux-plugins/tpm" "${HOME}/.tmux/plugins/tpm"

    if ! cp "${SCRIPT_DIR}/tmux/.tmux.conf" "${HOME}/"; then
        log_error "Failed to copy .tmux.conf"
        return 1
    fi

    log_success "Tmux configuration installed"
}

install_fd() {
    log_info "Installing fd..."

    local fd_dir="${SOFTWARES_DIR}/fdfind"
    local fd_url="https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"

    safe_remove "${fd_dir}"

    cd "${SOFTWARES_DIR}"
    download_and_extract "${fd_url}" "${SOFTWARES_DIR}"

    mv "fd-${FD_VERSION}-x86_64-unknown-linux-gnu" fdfind

    add_to_path "${fd_dir}"

    log_success "fd installed"
}

install_neovim() {
    log_info "Installing Neovim and LazyVim..."

    local nvim_dir="${SOFTWARES_DIR}/nvim"
    local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

    safe_remove "${nvim_dir}"

    cd "${SOFTWARES_DIR}"
    download_and_extract "${nvim_url}" "${SOFTWARES_DIR}"

    mv nvim-linux-x86_64 nvim

    # Install LazyVim starter
    local nvim_config="${HOME}/.config/nvim"
    clone_repo "https://github.com/LazyVim/starter" "${nvim_config}"

    # Copy custom configurations
    if ! cp "${SCRIPT_DIR}/nvim/config/options.lua" "${nvim_config}/lua/config/options.lua"; then
        log_error "Failed to copy nvim options.lua"
        return 1
    fi

    if ! cp "${SCRIPT_DIR}/nvim/plugins/"*.lua "${nvim_config}/lua/plugins/"; then
        log_error "Failed to copy nvim plugins"
        return 1
    fi

    # Remove .git directory from LazyVim starter
    safe_remove "${nvim_config}/.git"

    add_to_path "${nvim_dir}/bin"

    log_success "Neovim and LazyVim installed"
}

install_lazygit() {
    log_info "Installing lazygit..."

    local lazygit_dir="${SOFTWARES_DIR}/lazygit"
    local lazygit_url="https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"

    safe_remove "${lazygit_dir}"
    mkdir -p "${lazygit_dir}"

    cd "${SOFTWARES_DIR}"
    download_and_extract "${lazygit_url}" "${lazygit_dir}"

    add_to_path "${lazygit_dir}"

    log_success "lazygit installed"
}

install_golang() {
    log_info "Installing Go..."

    local go_dir="${SOFTWARES_DIR}/go"
    local go_url="https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"

    safe_remove "${go_dir}"

    cd "${SOFTWARES_DIR}"
    download_and_extract "${go_url}" "${SOFTWARES_DIR}"

    add_to_path "${go_dir}/bin"

    log_success "Go installed"
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    log_info "Starting development environment setup..."
    log_info "Script directory: ${SCRIPT_DIR}"

    # Create softwares directory if it doesn't exist
    if [[ ! -d "${SOFTWARES_DIR}" ]]; then
        log_info "Creating softwares directory: ${SOFTWARES_DIR}"
        mkdir -p "${SOFTWARES_DIR}"
    fi

    # Run installations
    install_system_packages
    install_oh_my_zsh
    install_tmux
    install_fd
    install_neovim
    install_lazygit
    install_golang

    log_success "=========================================="
    log_success "Installation completed successfully!"
    log_success "=========================================="
    log_info "Please restart your terminal or run: source ~/.zshrc"
    log_info "For tmux plugins, press prefix + I (Ctrl-F + I) inside tmux"
}

# Run main function
main "$@"
