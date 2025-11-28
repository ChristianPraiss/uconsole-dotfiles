#!/bin/bash
#
# Module: Core Sway/Wayland System
# Description: Installs core Sway window manager and Wayland components
# Dependencies: none
#
# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="sway-core"
MODULE_NAME="Core Sway/Wayland System"
MODULE_DESCRIPTION="Sway window manager & core Wayland tools"
MODULE_DEPENDENCIES=()

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Package list
    local packages=(
        sway
        swayidle
        swaylock
        swaybg
        wl-clipboard
        wtype
        wlr-randr
        xdg-utils
        xdg-desktop-portal-wlr
        dunst
    )

    # Install packages
    if apt_install "${packages[@]}"; then
        print_success "Core Sway/Wayland components installed successfully"
        return 0
    else
        print_error "Failed to install Core Sway/Wayland components"
        return 1
    fi
}

# Check if module is already installed
check_installed() {
    # Check if sway is installed
    if apt_check_installed "sway"; then
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
