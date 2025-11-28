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
MODULE_DESCRIPTION="Wofi, Qutebrowser, Neovim, bluetuith, system utilities"
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
        wget
        jq
        pavucontrol
    )

    # Install packages
    if ! apt_install "${packages[@]}"; then
        print_error "Failed to install Applications & Utilities"
        return 1
    fi

    # Install bluetuith (Bluetooth TUI manager)
    print_info "Installing bluetuith..."
    if ! command -v bluetuith &> /dev/null; then
        # Try apt first
        if ! apt_install bluetuith; then
            print_warning "bluetuith not available in repositories, installing from GitHub..."

            # Install from GitHub releases
            local BLUETUITH_VERSION="0.2.3"
            local ARCH="arm64"  # uConsole is ARM-based
            local TEMP_DIR=$(mktemp -d)

            wget -q "https://github.com/darkhz/bluetuith/releases/download/v${BLUETUITH_VERSION}/bluetuith_${BLUETUITH_VERSION}_linux_${ARCH}.tar.gz" -O "${TEMP_DIR}/bluetuith.tar.gz"

            if [ $? -eq 0 ]; then
                tar -xzf "${TEMP_DIR}/bluetuith.tar.gz" -C "${TEMP_DIR}"
                sudo mv "${TEMP_DIR}/bluetuith" /usr/local/bin/
                sudo chmod +x /usr/local/bin/bluetuith
                rm -rf "${TEMP_DIR}"
                print_success "bluetuith installed from GitHub"
            else
                print_warning "Failed to install bluetuith from GitHub, skipping..."
            fi
        fi
    else
        print_info "bluetuith already installed"
    fi

    print_success "Applications & Utilities installed successfully"
    return 0
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
