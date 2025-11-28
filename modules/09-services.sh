#!/bin/bash
#
# Module: System Services
# Description: Enables and starts system services
# Dependencies: applications, dotfiles
#

# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="services"
MODULE_NAME="System Services"
MODULE_DESCRIPTION="NetworkManager, Bluetooth, systemd services"
MODULE_DEPENDENCIES=("applications" "dotfiles")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Configure WiFi and Bluetooth
    print_info "Enabling and starting system services..."

    if sudo systemctl enable --now NetworkManager; then
        print_info "NetworkManager enabled and started"
    else
        print_warning "Failed to enable NetworkManager"
    fi

    if sudo systemctl enable --now bluetooth; then
        print_info "Bluetooth enabled and started"
    else
        print_warning "Failed to enable Bluetooth"
    fi

    # Restart logind to apply power button configuration
    print_info "Restarting systemd-logind to apply power button configuration..."
    if sudo systemctl restart systemd-logind; then
        print_info "systemd-logind restarted successfully"
    else
        print_warning "Failed to restart systemd-logind"
    fi

    print_success "System services configured successfully"
    return 0
}

# Check if module is already installed
check_installed() {
    # Check if NetworkManager is enabled
    if systemctl is-enabled NetworkManager &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "30"  # ~30 seconds
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
