#!/bin/bash
#
# Module: Terminal & Shell Environment
# Description: Installs terminal emulator, shell, and prompt
# Dependencies: none
#

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/package-manager.sh"

# Module metadata
MODULE_ID="terminal-shell"
MODULE_NAME="Terminal & Shell Environment"
MODULE_DESCRIPTION="Kitty, Zsh, Starship prompt"
MODULE_DEPENDENCIES=()

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Package list
    local packages=(
        kitty
        zsh
        git
        curl
        wget
        unzip
    )

    # Install packages
    if ! apt_install "${packages[@]}"; then
        print_error "Failed to install terminal and shell packages"
        return 1
    fi

    # Install Starship prompt
    print_info "Installing Starship prompt..."
    if ! check_command starship; then
        if curl -sS https://starship.rs/install.sh | sh -s -- -y; then
            print_success "Starship installed successfully"
        else
            print_error "Failed to install Starship"
            return 1
        fi
    else
        print_info "Starship already installed, skipping..."
    fi

    # Change default shell to zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to zsh..."
        if chsh -s "$(which zsh)"; then
            print_success "Default shell changed to zsh. You'll need to log out and back in for this to take effect."
        else
            print_warning "Failed to change default shell. You may need to run: chsh -s \$(which zsh)"
        fi
    else
        print_info "Default shell is already zsh, skipping..."
    fi

    print_success "Terminal & Shell Environment installed successfully"
    return 0
}

# Check if module is already installed
check_installed() {
    # Check if kitty and zsh are installed
    if apt_check_installed "kitty" && apt_check_installed "zsh"; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "120"  # ~2 minutes
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
