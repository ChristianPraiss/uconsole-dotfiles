#!/bin/bash
#
# Module: Fonts
# Description: Installs system fonts and Nerd Fonts
# Dependencies: terminal-shell
#

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/package-manager.sh"

# Module metadata
MODULE_ID="fonts"
MODULE_NAME="Fonts"
MODULE_DESCRIPTION="System fonts, JetBrainsMono Nerd Font, Departure Mono"
MODULE_DEPENDENCIES=("terminal-shell")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Install system fonts
    local packages=(
        fonts-terminus
        fonts-font-awesome
        fonts-noto
        fonts-noto-color-emoji
    )

    if ! apt_install "${packages[@]}"; then
        print_error "Failed to install system fonts"
        return 1
    fi

    # Create font directory
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    # Install JetBrainsMono Nerd Font
    print_info "Installing JetBrainsMono Nerd Font..."
    if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
        print_info "Downloading JetBrainsMono Nerd Font (this may take a moment)..."
        if wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -O /tmp/JetBrainsMono.zip; then
            if [ -f /tmp/JetBrainsMono.zip ]; then
                unzip -q /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono
                find /tmp/JetBrainsMono -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
                rm -rf /tmp/JetBrainsMono /tmp/JetBrainsMono.zip
                print_info "JetBrainsMono Nerd Font installed"
            else
                print_warning "Failed to download JetBrainsMono Nerd Font, skipping..."
            fi
        else
            print_warning "Failed to download JetBrainsMono Nerd Font, skipping..."
        fi
    else
        print_info "JetBrainsMono Nerd Font already installed, skipping..."
    fi

    # Install Departure Mono
    print_info "Installing Departure Mono font..."
    if [ ! -f "$FONT_DIR/DepartureMono-Regular.otf" ]; then
        # Get the actual download URL from GitHub API
        DEPARTURE_URL=$(curl -s https://api.github.com/repos/rektdeckard/departure-mono/releases/latest | grep "browser_download_url.*zip" | cut -d '"' -f 4)

        if [ -n "$DEPARTURE_URL" ]; then
            if wget -q "$DEPARTURE_URL" -O /tmp/DepartureMono.zip; then
                if [ -f /tmp/DepartureMono.zip ]; then
                    unzip -q /tmp/DepartureMono.zip -d /tmp/DepartureMono
                    find /tmp/DepartureMono -name "*.otf" -exec cp {} "$FONT_DIR/" \; 2>/dev/null || \
                    find /tmp/DepartureMono -name "*.ttf" -exec cp {} "$FONT_DIR/" \; 2>/dev/null || true
                    rm -rf /tmp/DepartureMono /tmp/DepartureMono.zip
                    print_info "Departure Mono font installed"
                else
                    print_warning "Failed to download Departure Mono, skipping..."
                fi
            else
                print_warning "Failed to download Departure Mono, skipping..."
            fi
        else
            print_warning "Could not find Departure Mono download URL, skipping..."
        fi
    else
        print_info "Departure Mono font already installed, skipping..."
    fi

    # Rebuild font cache
    print_info "Rebuilding font cache..."
    fc-cache -f

    print_success "Fonts installed successfully"
    return 0
}

# Check if module is already installed
check_installed() {
    # Check if system fonts are installed
    if apt_check_installed "fonts-terminus"; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "240"  # ~4 minutes (downloads can be slow)
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
