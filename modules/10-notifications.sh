#!/bin/bash
#
# Module: Notification Center
# Description: SwayNotificationCenter with Catppuccin Mocha theme
# Dependencies: sway-core
#

# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="notifications"
MODULE_NAME="Notification Center"
MODULE_DESCRIPTION="SwayNC with Catppuccin Mocha theme"
MODULE_DEPENDENCIES=("sway-core")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Install build dependencies
    print_info "Installing build dependencies..."
    if ! apt_install meson ninja-build libgtk-3-dev libgtk-layer-shell-dev \
                     libjson-glib-dev libglib2.0-dev scdoc libpulse-dev \
                     valac git; then
        print_error "Failed to install build dependencies"
        return 1
    fi

    # Create temporary build directory
    BUILD_DIR="/tmp/swaync-build-$$"
    mkdir -p "$BUILD_DIR"

    print_info "Cloning SwayNC repository..."
    if ! git clone https://github.com/ErikReider/SwayNotificationCenter.git "$BUILD_DIR"; then
        print_error "Failed to clone SwayNC repository"
        rm -rf "$BUILD_DIR"
        return 1
    fi

    # Build and install SwayNC
    print_info "Building SwayNC from source (this may take a few minutes)..."
    cd "$BUILD_DIR" || return 1

    if ! meson setup build; then
        print_error "Meson setup failed"
        cd - > /dev/null
        rm -rf "$BUILD_DIR"
        return 1
    fi

    if ! ninja -C build; then
        print_error "Build failed"
        cd - > /dev/null
        rm -rf "$BUILD_DIR"
        return 1
    fi

    print_info "Installing SwayNC..."
    if ! sudo ninja -C build install; then
        print_error "Installation failed"
        cd - > /dev/null
        rm -rf "$BUILD_DIR"
        return 1
    fi

    cd - > /dev/null
    rm -rf "$BUILD_DIR"
    print_success "SwayNC built and installed successfully"

    # Create SwayNC config directory
    print_info "Creating SwayNC configuration directory..."
    mkdir -p "$HOME/.config/swaync"

    # Download Catppuccin Mocha theme
    print_info "Downloading Catppuccin Mocha theme..."
    if ! wget -q -O "$HOME/.config/swaync/style.css" \
        https://github.com/catppuccin/swaync/releases/latest/download/catppuccin-mocha.css; then
        print_error "Failed to download Catppuccin Mocha theme"
        return 1
    fi

    # Modify font in style.css to use JetBrainsMono Nerd Font
    print_info "Customizing font in theme..."
    if [ -f "$HOME/.config/swaync/style.css" ]; then
        sed -i "s/'Ubuntu Nerd Font'/'JetBrainsMono Nerd Font'/g" "$HOME/.config/swaync/style.css"
        print_success "Theme customized with JetBrainsMono Nerd Font"
    else
        print_warning "Style file not found, skipping font customization"
    fi

    # Deploy config.json from dotfiles
    print_info "Deploying SwayNC configuration..."
    repo_dir="$(get_script_dir)"
    if [ -f "$repo_dir/.config/swaync/config.json" ]; then
        cp "$repo_dir/.config/swaync/config.json" "$HOME/.config/swaync/"
        print_success "SwayNC configuration deployed"
    else
        print_warning "Config file not found in repository, skipping..."
    fi

    print_success "Notification center installed successfully"
    return 0
}

# Check if module is already installed
check_installed() {
    # Check if swaync binary is available
    if command -v swaync &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "300"  # ~5 minutes (building from source)
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
