#!/bin/bash
#
# Module: Audio System (PipeWire)
# Description: Installs PipeWire audio stack
# Dependencies: none
#

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/package-manager.sh"

# Module metadata
MODULE_ID="audio"
MODULE_NAME="Audio System (PipeWire)"
MODULE_DESCRIPTION="PipeWire audio stack"
MODULE_DEPENDENCIES=()

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Package list
    local packages=(
        pipewire
        pipewire-alsa
        pipewire-pulse
        wireplumber
        pavucontrol
    )

    # Install packages
    if apt_install "${packages[@]}"; then
        print_success "PipeWire audio system installed successfully"
        return 0
    else
        print_error "Failed to install PipeWire audio system"
        return 1
    fi
}

# Check if module is already installed
check_installed() {
    # Check if pipewire is installed
    if apt_check_installed "pipewire"; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "90"  # ~1.5 minutes
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
