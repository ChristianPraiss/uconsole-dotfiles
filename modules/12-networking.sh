#!/bin/bash
#
# Module: Networking & Firewall
# Description: Configures UFW firewall and SSH server
# Dependencies: none
#

# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="networking"
MODULE_NAME="Networking & Firewall"
MODULE_DESCRIPTION="UFW firewall with SSH access on port 22"
MODULE_DEPENDENCIES=()

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Install required packages
    print_info "Installing ufw and openssh-server..."
    if ! apt_install ufw openssh-server; then
        print_error "Failed to install required packages"
        return 1
    fi

    # Configure UFW firewall
    print_info "Configuring UFW firewall..."

    # Set default policies - deny all incoming, allow outgoing
    sudo ufw --force default deny incoming
    sudo ufw --force default allow outgoing

    # Allow SSH on port 22
    print_info "Allowing SSH on port 22..."
    sudo ufw allow 22/tcp

    # Enable UFW
    print_info "Enabling UFW firewall..."
    sudo ufw --force enable

    # Enable and start SSH server
    print_info "Enabling and starting SSH server..."
    if sudo systemctl enable --now ssh; then
        print_info "SSH server enabled and started on port 22"
    else
        print_warning "Failed to enable SSH server"
        return 1
    fi

    # Show firewall status
    print_info "Firewall configuration:"
    sudo ufw status verbose

    print_success "Networking & Firewall configured successfully"
    print_info "SSH server is running on port 22"
    print_info "All other incoming ports are blocked by UFW"
    return 0
}

# Check if module is already installed
check_installed() {
    # Check if UFW is installed and enabled
    if apt_check_installed ufw && sudo ufw status | grep -q "Status: active"; then
        # Also check if SSH is enabled
        if systemctl is-enabled ssh &>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Estimate installation time (seconds)
estimate_time() {
    echo "60"  # ~60 seconds
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
