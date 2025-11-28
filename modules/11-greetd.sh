#!/bin/bash
#
# Module: Display Manager (greetd)
# Description: greetd display manager with tuigreet TUI greeter
# Dependencies: sway-core
#

# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="greetd"
MODULE_NAME="Display Manager (greetd)"
MODULE_DESCRIPTION="greetd with tuigreet TUI greeter"
MODULE_DEPENDENCIES=("sway-core")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Install greetd from apt
    print_info "Installing greetd..."
    if ! apt_install greetd; then
        print_error "Failed to install greetd"
        return 1
    fi

    # Install tuigreet from GitHub releases (not available in Debian repos)
    print_info "Installing tuigreet from GitHub releases..."

    # Detect architecture
    local arch=$(dpkg --print-architecture)
    if [ "$arch" = "armhf" ]; then
        local tuigreet_arch="armv7-unknown-linux-gnueabihf"
    elif [ "$arch" = "arm64" ]; then
        local tuigreet_arch="aarch64-unknown-linux-gnu"
    elif [ "$arch" = "amd64" ]; then
        local tuigreet_arch="x86_64-unknown-linux-gnu"
    else
        print_error "Unsupported architecture: $arch"
        return 1
    fi

    # Get latest release version
    local version="0.9.1"  # Known stable version
    local download_url="https://github.com/apognu/tuigreet/releases/download/${version}/tuigreet-${version}-${tuigreet_arch}"

    print_info "Downloading tuigreet binary..."
    if ! sudo wget -q --show-progress -O /usr/local/bin/tuigreet "$download_url"; then
        print_error "Failed to download tuigreet"
        return 1
    fi

    # Make it executable
    sudo chmod +x /usr/local/bin/tuigreet

    # Verify installation
    if [ ! -x /usr/local/bin/tuigreet ]; then
        print_error "tuigreet binary is not executable"
        return 1
    fi

    print_success "tuigreet installed successfully"

    # Backup existing greetd configuration if it exists
    if [ -f /etc/greetd/config.toml ]; then
        print_warning "Backing up existing /etc/greetd/config.toml"
        sudo cp /etc/greetd/config.toml /etc/greetd/config.toml.backup
    fi

    # Create greetd configuration directory
    sudo mkdir -p /etc/greetd

    # Deploy greetd configuration from repository or create it
    local repo_dir="$(get_script_dir)"
    if [ -f "$repo_dir/etc/greetd/config.toml" ]; then
        print_info "Deploying greetd configuration from repository..."
        sudo cp "$repo_dir/etc/greetd/config.toml" /etc/greetd/
        print_success "greetd configuration deployed"
    else
        # Fallback: create configuration inline
        print_info "Creating greetd configuration..."
        sudo tee /etc/greetd/config.toml > /dev/null <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-session --cmd sway"
user = "greeter"
EOF
        print_success "greetd configuration created"
    fi

    # Enable greetd service (but don't start it - would kill current session)
    print_info "Enabling greetd service..."
    if sudo systemctl enable greetd; then
        print_success "greetd service enabled"
    else
        print_error "Failed to enable greetd service"
        return 1
    fi

    print_success "greetd installed and configured successfully"
    print_warning "IMPORTANT: Please reboot for greetd to take effect"
    print_info "After reboot, you'll be greeted by the tuigreet TUI login screen"

    return 0
}

# Check if module is already installed
check_installed() {
    # Check if greetd service is enabled and tuigreet binary exists
    if systemctl is-enabled greetd &>/dev/null && [ -x /usr/local/bin/tuigreet ]; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "90"  # ~1.5 minutes (greetd package + tuigreet binary download)
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
