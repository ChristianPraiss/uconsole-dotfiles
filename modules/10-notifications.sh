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

    # Install swaync package
    if ! apt_install "swaync"; then
        print_error "Failed to install swaync"
        return 1
    fi

    # Create SwayNC config directory
    print_info "Creating SwayNC configuration directory..."
    mkdir -p "$HOME/.config/swaync"

    # Download Catppuccin Mocha theme
    print_info "Downloading Catppuccin Mocha theme..."
    if ! wget -q -O "$HOME/.config/swaync/style.css" \
        https://github.com/catppuccin/swaync/releases/latest/download/mocha.css; then
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
    # Check if swaync package is installed
    if apt_check_installed "swaync"; then
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
