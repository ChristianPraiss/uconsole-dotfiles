#!/bin/bash
#
# Module: Applications & Utilities
# Description: Installs application launcher and system utilities
# Dependencies: sway-core
#

# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="applications"
MODULE_NAME="Applications & Utilities"
MODULE_DESCRIPTION="Wofi, Qutebrowser, Neovim, system utilities"
MODULE_DEPENDENCIES=("sway-core")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Package list
    local packages=(
        wofi
        qutebrowser
        nautilus
        neovim
        htop
        brightnessctl
        alsa-utils
        bluez
        network-manager
        systemd
        gnome-themes-extra
    )

    # Install packages
    if apt_install "${packages[@]}"; then
        print_success "Applications & Utilities installed successfully"
        return 0
    else
        print_error "Failed to install Applications & Utilities"
        return 1
    fi
}

# Check if module is already installed
check_installed() {
    # Check if wofi and neovim are installed
    if apt_check_installed "wofi" && apt_check_installed "neovim"; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "150"  # ~2.5 minutes
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
