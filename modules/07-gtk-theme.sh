#!/bin/bash
#
# Module: GTK Theme (Catppuccin Mocha)
# Description: Installs and configures Catppuccin Mocha GTK theme
# Dependencies: terminal-shell
#

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/package-manager.sh"

# Module metadata
MODULE_ID="gtk-theme"
MODULE_NAME="GTK Theme (Catppuccin Mocha)"
MODULE_DESCRIPTION="Catppuccin Mocha theme with gsettings"
MODULE_DEPENDENCIES=("terminal-shell")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    THEME_DIR="$HOME/.themes"
    mkdir -p "$THEME_DIR"

    if [ ! -d "$THEME_DIR/catppuccin-mocha-mauve-standard+default" ]; then
        print_info "Downloading Catppuccin GTK theme..."

        # Clone the repository
        if [ -d /tmp/catppuccin-gtk ]; then
            rm -rf /tmp/catppuccin-gtk
        fi

        if ! git clone --depth=1 https://github.com/catppuccin/gtk.git /tmp/catppuccin-gtk; then
            print_error "Failed to clone Catppuccin GTK theme"
            return 1
        fi

        if [ -d /tmp/catppuccin-gtk ]; then
            cd /tmp/catppuccin-gtk

            # Install dependencies for building
            if ! apt_install sassc; then
                print_error "Failed to install sassc"
                cd "$(get_script_dir)"
                rm -rf /tmp/catppuccin-gtk
                return 1
            fi

            # Build and install Mocha variant with Mauve accent
            print_info "Building Catppuccin Mocha theme..."
            if python3 install.py mocha mauve --dest "$THEME_DIR"; then
                print_success "Catppuccin Mocha GTK theme installed"
            else
                print_error "Failed to build Catppuccin GTK theme"
                cd "$(get_script_dir)"
                rm -rf /tmp/catppuccin-gtk
                return 1
            fi

            cd "$(get_script_dir)"
            rm -rf /tmp/catppuccin-gtk
        else
            print_error "Failed to clone Catppuccin GTK theme"
            return 1
        fi
    else
        print_info "Catppuccin Mocha GTK theme already installed, skipping..."
    fi

    # Configure GTK theme using gsettings for GNOME applications
    print_info "Configuring GTK theme and dark mode preference..."
    if gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-mauve-standard+default' && \
       gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'; then
        print_success "GTK theme set to Catppuccin Mocha with dark mode"
    else
        print_warning "Failed to configure GTK theme via gsettings"
    fi

    print_success "GTK Theme installed and configured successfully"
    return 0
}

# Check if module is already installed
check_installed() {
    # Check if theme directory exists
    if [ -d "$HOME/.themes/catppuccin-mocha-mauve-standard+default" ]; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "180"  # ~3 minutes (git clone + build)
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
