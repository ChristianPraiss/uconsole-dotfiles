#!/bin/bash
#
# Module: Screenshot Tools
# Description: Installs screenshot utilities for Wayland
# Dependencies: sway-core
#

# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="screenshots"
MODULE_NAME="Screenshot Tools"
MODULE_DESCRIPTION="Grim, Slurp, Grimshot"
MODULE_DEPENDENCIES=("sway-core")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Package list
    local packages=(
        grim
        slurp
        jq
    )

    # Install packages
    if ! apt_install "${packages[@]}"; then
        print_error "Failed to install screenshot dependencies"
        return 1
    fi

    # Install grimshot (usually in sway-contrib)
    if ! check_command grimshot; then
        print_info "Installing grimshot manually..."
        if sudo wget -O /usr/local/bin/grimshot \
            https://raw.githubusercontent.com/swaywm/sway/master/contrib/grimshot; then
            sudo chmod +x /usr/local/bin/grimshot
            print_success "Grimshot installed successfully"
        else
            print_error "Failed to download grimshot"
            return 1
        fi
    else
        print_info "Grimshot already installed, skipping..."
    fi

    # Create screenshots directory
    print_info "Creating screenshots directory..."
    mkdir -p "$HOME/Pictures/Screenshots"

    print_success "Screenshot tools installed successfully"
    return 0
}

# Check if module is already installed
check_installed() {
    # Check if grim and slurp are installed
    if apt_check_installed "grim" && apt_check_installed "slurp"; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "60"  # ~1 minute
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
