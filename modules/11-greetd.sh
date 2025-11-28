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

    # Check if tuigreet is already installed
    if [ -x /usr/local/bin/tuigreet ]; then
        print_info "tuigreet is already installed, skipping build"
    else
        # Install build dependencies for tuigreet
        print_info "Installing Rust toolchain and build dependencies..."
        if ! apt_install cargo rustc git pkg-config libpam0g-dev; then
            print_error "Failed to install build dependencies"
            return 1
        fi

        # Clone tuigreet repository
        print_info "Cloning tuigreet from GitHub..."
        local build_dir="/tmp/tuigreet-build-$$"
        if ! git clone https://github.com/apognu/tuigreet.git "$build_dir"; then
            print_error "Failed to clone tuigreet repository"
            return 1
        fi

        # Build tuigreet from source
        print_info "Compiling tuigreet (this may take several minutes)..."
        cd "$build_dir" || return 1

        if ! cargo build --release; then
            print_error "Failed to compile tuigreet"
            cd -
            rm -rf "$build_dir"
            return 1
        fi

        # Install compiled binary
        print_info "Installing tuigreet binary..."
        if ! sudo install -m 755 target/release/tuigreet /usr/local/bin/tuigreet; then
            print_error "Failed to install tuigreet binary"
            cd -
            rm -rf "$build_dir"
            return 1
        fi

        # Cleanup build directory
        cd -
        rm -rf "$build_dir"

        # Verify installation
        if [ ! -x /usr/local/bin/tuigreet ]; then
            print_error "tuigreet binary is not executable"
            return 1
        fi

        print_success "tuigreet compiled and installed successfully"
    fi

    # Create greeter user if it doesn't exist
    if ! id greeter &>/dev/null; then
        print_info "Creating greeter user..."
        if sudo useradd -M -G video greeter; then
            sudo passwd -d greeter  # No password needed for greeter user
            print_success "greeter user created"
        else
            print_error "Failed to create greeter user"
            return 1
        fi
    else
        print_info "greeter user already exists"
    fi

    # Create systemd override to conflict with getty@tty1 (greetd uses VT1)
    print_info "Creating greetd systemd override..."
    sudo mkdir -p /etc/systemd/system/greetd.service.d

    local repo_dir="$(get_script_dir)"
    if [ -f "$repo_dir/etc/systemd/system/greetd.service.d/override.conf" ]; then
        print_info "Deploying greetd systemd override from repository..."
        sudo cp "$repo_dir/etc/systemd/system/greetd.service.d/override.conf" \
                /etc/systemd/system/greetd.service.d/
    else
        # Fallback: create override inline
        sudo tee /etc/systemd/system/greetd.service.d/override.conf > /dev/null <<'EOF'
[Unit]
After=systemd-user-sessions.service plymouth-quit-wait.service
After=getty@tty1.service
Conflicts=getty@tty1.service
EOF
    fi
    print_success "greetd systemd override created"

    # Reload systemd to apply override
    print_info "Reloading systemd daemon..."
    sudo systemctl daemon-reload

    # Stop and disable getty@tty1 to prevent conflicts with greetd
    print_info "Stopping and disabling getty@tty1..."
    sudo systemctl stop getty@tty1 &>/dev/null || true
    sudo systemctl disable getty@tty1 &>/dev/null || true
    print_success "getty@tty1 stopped and disabled"

    # Backup existing greetd configuration if it exists
    if [ -f /etc/greetd/config.toml ]; then
        print_warning "Backing up existing /etc/greetd/config.toml"
        sudo cp /etc/greetd/config.toml /etc/greetd/config.toml.backup
    fi

    # Create greetd configuration directory
    sudo mkdir -p /etc/greetd

    # Deploy greetd configuration from repository or create it
    print_info "Deploying greetd configuration from repository..."
    sudo cp "$repo_dir/etc/greetd/config.toml" /etc/greetd/
    print_success "greetd configuration deployed"

    # Set default target to graphical.target (required for display-manager.service)
    print_info "Setting default target to graphical.target..."
    if sudo systemctl set-default graphical.target; then
        print_success "Default target set to graphical.target"
    else
        print_warning "Failed to set default target"
    fi

    # Enable and start greetd service
    print_info "Enabling greetd service..."
    if sudo systemctl enable greetd; then
        print_success "greetd service enabled"
    else
        print_error "Failed to enable greetd service"
        return 1
    fi

    print_info "Starting greetd service..."
    if sudo systemctl start greetd; then
        print_success "greetd service started"
    else
        print_warning "Failed to start greetd service (may require reboot)"
    fi

    print_success "greetd installed and configured successfully"
    print_info "tuigreet login screen is now active on VT1"
    print_info "Switch to VT1 (Ctrl+Alt+F1) to see the login screen"

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
    echo "600"  # ~10 minutes (greetd package + Rust toolchain + tuigreet compilation)
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
