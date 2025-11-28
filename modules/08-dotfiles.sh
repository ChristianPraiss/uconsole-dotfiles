#!/bin/bash
#
# Module: Dotfiles Deployment
# Description: Backs up and deploys dotfiles and configurations
# Dependencies: All other modules
#

# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="dotfiles"
MODULE_NAME="Dotfiles Deployment"
MODULE_DESCRIPTION="Install configuration files"
MODULE_DEPENDENCIES=("sway-core" "audio" "terminal-shell" "applications" "screenshots" "fonts" "gtk-theme")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Create necessary directories
    print_info "Creating necessary directories..."
    mkdir -p "$HOME/.config"

    # Create backup directory
    local backup_dir=$(create_backup_dir)
    if [ $? -ne 0 ]; then
        print_error "Failed to create backup directory"
        return 1
    fi

    # Backup existing configs
    print_info "Backing up existing configurations..."

    # Backup shell config files
    for file in .zshrc .zprofile .zshenv; do
        if [ -f "$HOME/$file" ]; then
            print_warning "Backing up existing $file to $backup_dir"
            backup_file "$HOME/$file" "$backup_dir"
        fi
    done

    # Backup config directories
    for dir in sway nvim qutebrowser htop kitty gtk-3.0 gtk-4.0; do
        if [ -d "$HOME/.config/$dir" ]; then
            print_warning "Backing up existing .config/$dir to $backup_dir"
            backup_directory "$HOME/.config/$dir" "$backup_dir"
        fi
    done

    # Copy dotfiles
    print_info "Installing dotfiles..."
    local repo_dir="$(get_script_dir)"

    cp "$repo_dir/.zshrc" "$HOME/"
    cp "$repo_dir/.zprofile" "$HOME/"
    cp "$repo_dir/.zshenv" "$HOME/"

    cp -r "$repo_dir/.config"/* "$HOME/.config/"

    # Make scripts executable
    if [ -d "$HOME/.config/sway/scripts" ]; then
        chmod +x "$HOME/.config/sway/scripts/"*.sh
    fi

    # Configure system power button handling
    print_info "Configuring power button to use Sway instead of systemd..."
    sudo mkdir -p /etc/systemd/logind.conf.d
    if [ -f "$repo_dir/etc/systemd/logind.conf.d/power-button.conf" ]; then
        sudo cp "$repo_dir/etc/systemd/logind.conf.d/power-button.conf" /etc/systemd/logind.conf.d/
        print_info "Power button will now open power menu instead of shutting down immediately"
    else
        print_warning "Power button config not found, skipping..."
    fi

    print_success "Dotfiles deployed successfully"
    print_info "Old configs have been backed up to: $backup_dir"

    return 0
}

# Check if module is already installed
check_installed() {
    # Check if basic dotfiles exist
    if [ -f "$HOME/.zshrc" ] && [ -d "$HOME/.config/sway" ]; then
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
