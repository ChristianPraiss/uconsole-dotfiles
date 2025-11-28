#!/bin/bash
#
# Module: Display Manager (SDDM)
# Description: SDDM display manager with Catppuccin Mocha theme
# Dependencies: sway-core
#

# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="sddm"
MODULE_NAME="Display Manager (SDDM)"
MODULE_DESCRIPTION="SDDM with Catppuccin Mocha theme"
MODULE_DEPENDENCIES=("sway-core")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Install SDDM and QML dependencies
    print_info "Installing SDDM and dependencies..."
    if ! apt_install sddm qml-module-qtquick-layouts qml-module-qtquick-controls2 \
                     qml-module-qtquick-window2 libqt6svg6; then
        print_error "Failed to install SDDM packages"
        return 1
    fi

    # Download Catppuccin SDDM theme
    print_info "Downloading Catppuccin SDDM theme..."
    local temp_dir="/tmp/catppuccin-sddm"

    # Clean up any existing temp directory
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi

    mkdir -p "$temp_dir"

    if ! wget -q -O "$temp_dir/catppuccin-mocha.zip" \
        https://github.com/catppuccin/sddm/releases/latest/download/catppuccin-mocha.zip; then
        print_error "Failed to download Catppuccin SDDM theme"
        rm -rf "$temp_dir"
        return 1
    fi

    # Extract theme
    print_info "Extracting theme..."
    if ! unzip -q "$temp_dir/catppuccin-mocha.zip" -d "$temp_dir"; then
        print_error "Failed to extract theme"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install theme to system directory
    print_info "Installing theme to /usr/share/sddm/themes/..."
    sudo mkdir -p /usr/share/sddm/themes

    # The zip contains catppuccin-mocha directory
    if [ -d "$temp_dir/catppuccin-mocha" ]; then
        sudo cp -r "$temp_dir/catppuccin-mocha" /usr/share/sddm/themes/
        print_success "Theme installed successfully"
    else
        print_error "Theme directory not found in downloaded archive"
        rm -rf "$temp_dir"
        return 1
    fi

    # Clean up temp directory
    rm -rf "$temp_dir"

    # Backup existing SDDM configuration
    if [ -f /etc/sddm.conf ]; then
        print_warning "Backing up existing /etc/sddm.conf"
        sudo cp /etc/sddm.conf /etc/sddm.conf.backup
    fi

    if [ -d /etc/sddm.conf.d ]; then
        print_warning "Backing up existing /etc/sddm.conf.d"
        sudo cp -r /etc/sddm.conf.d /etc/sddm.conf.d.backup
    fi

    # Create SDDM configuration directory
    sudo mkdir -p /etc/sddm.conf.d

    # Deploy SDDM configuration from repository
    local repo_dir="$(get_script_dir)"
    if [ -f "$repo_dir/etc/sddm.conf.d/theme.conf" ]; then
        print_info "Deploying SDDM configuration..."
        sudo cp "$repo_dir/etc/sddm.conf.d/theme.conf" /etc/sddm.conf.d/
        print_success "SDDM configuration deployed"
    else
        # Fallback: create configuration inline
        print_info "Creating SDDM configuration..."
        sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=catppuccin-mocha
CursorTheme=breeze_cursors

[General]
# Use Wayland instead of X11
DisplayServer=wayland

[Wayland]
# Sway session command
SessionCommand=/usr/bin/sway
EOF
        print_success "SDDM configuration created"
    fi

    # Create Sway Wayland session file if it doesn't exist
    if [ ! -f /usr/share/wayland-sessions/sway.desktop ]; then
        print_info "Creating Sway Wayland session file..."
        sudo mkdir -p /usr/share/wayland-sessions

        if [ -f "$repo_dir/etc/wayland-sessions/sway.desktop" ]; then
            sudo cp "$repo_dir/etc/wayland-sessions/sway.desktop" /usr/share/wayland-sessions/
        else
            # Fallback: create session file inline
            sudo tee /usr/share/wayland-sessions/sway.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Sway
Comment=An i3-compatible Wayland compositor
Exec=sway
Type=Application
EOF
        fi
        print_success "Sway session file created"
    else
        print_info "Sway session file already exists"
    fi

    # Enable SDDM service (but don't start it - would kill current session)
    print_info "Enabling SDDM service..."
    if sudo systemctl enable sddm; then
        print_success "SDDM service enabled"
    else
        print_error "Failed to enable SDDM service"
        return 1
    fi

    print_success "SDDM installed and configured successfully"
    print_warning "IMPORTANT: Please reboot for SDDM to take effect"
    print_info "After reboot, you'll be greeted by the Catppuccin Mocha login screen"

    return 0
}

# Check if module is already installed
check_installed() {
    # Check if SDDM service is enabled
    if systemctl is-enabled sddm &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "180"  # ~3 minutes (packages + theme download)
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
