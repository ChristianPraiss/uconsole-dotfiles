#!/bin/bash
#
# Package manager library
# Provides APT wrapper functions with caching and error handling
#

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Track if apt update has been run this session
APT_UPDATED=false

# Update package lists (with caching to avoid repeated updates)
apt_update() {
    if [ "$APT_UPDATED" = true ]; then
        return 0
    fi

    print_info "Updating package lists..."
    if sudo apt update; then
        APT_UPDATED=true
        return 0
    else
        print_error "Failed to update package lists"
        return 1
    fi
}

# Install packages with error handling
# Usage: apt_install package1 package2 package3 ...
apt_install() {
    local packages=("$@")

    if [ ${#packages[@]} -eq 0 ]; then
        print_error "No packages specified for installation"
        return 1
    fi

    # Ensure apt is updated first
    apt_update || return 1

    print_info "Installing packages: ${packages[*]}"
    if sudo apt install -y "${packages[@]}"; then
        return 0
    else
        print_error "Failed to install packages: ${packages[*]}"
        return 1
    fi
}

# Check if a package is installed
# Usage: apt_check_installed package_name
apt_check_installed() {
    if dpkg -l "$1" 2>/dev/null | grep -q "^ii"; then
        return 0
    else
        return 1
    fi
}
