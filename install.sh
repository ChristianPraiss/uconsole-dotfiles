#!/bin/bash

set -e

echo "=========================================="
echo "uConsole Dotfiles Installation Script"
echo "=========================================="
echo ""

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Debian
if ! command -v apt &> /dev/null; then
    print_error "This script requires Debian/Ubuntu with apt package manager"
    exit 1
fi

print_info "Updating package lists..."
sudo apt update

print_info "Installing core Sway and Wayland components..."
sudo apt install -y \
    sway \
    swayidle \
    swaylock \
    swaybg \
    wl-clipboard \
    wtype \
    wlr-randr \
    xdg-utils \
    xdg-desktop-portal-wlr

print_info "Installing terminal and shell..."
sudo apt install -y \
    kitty \
    zsh \
    git \
    curl \
    wget \
    unzip

print_info "Installing application launcher and utilities..."
sudo apt install -y \
    wofi \
    qutebrowser \
    nautilus \
    neovim \
    htop

print_info "Installing system utilities..."
sudo apt install -y \
    brightnessctl \
    alsa-utils \
    bluez \
    network-manager \
    systemd \
    gnome-themes-extra

print_info "Installing screenshot dependencies..."
sudo apt install -y \
    grim \
    slurp \
    jq

# Install grimshot (usually in sway-contrib)
if ! command -v grimshot &> /dev/null; then
    print_info "Installing grimshot manually..."
    sudo wget -O /usr/local/bin/grimshot \
        https://raw.githubusercontent.com/swaywm/sway/master/contrib/grimshot
    sudo chmod +x /usr/local/bin/grimshot
fi

print_info "Installing fonts..."
sudo apt install -y \
    fonts-terminus \
    fonts-font-awesome \
    fonts-noto \
    fonts-noto-color-emoji

# Install Nerd Fonts
print_info "Installing JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    print_info "Downloading JetBrainsMono Nerd Font (this may take a moment)..."
    wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -O /tmp/JetBrainsMono.zip

    if [ -f /tmp/JetBrainsMono.zip ]; then
        unzip -q /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono
        find /tmp/JetBrainsMono -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
        rm -rf /tmp/JetBrainsMono /tmp/JetBrainsMono.zip
        print_info "JetBrainsMono Nerd Font installed"
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
        wget -q "$DEPARTURE_URL" -O /tmp/DepartureMono.zip
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
        print_warning "Could not find Departure Mono download URL, skipping..."
    fi
else
    print_info "Departure Mono font already installed, skipping..."
fi

fc-cache -f

# Install Catppuccin Mocha GTK theme
print_info "Installing Catppuccin Mocha GTK theme..."
THEME_DIR="$HOME/.themes"
mkdir -p "$THEME_DIR"

if [ ! -d "$THEME_DIR/catppuccin-mocha-mauve-standard+default" ]; then
    print_info "Downloading Catppuccin GTK theme..."

    # Clone the repository with submodules
    if [ -d /tmp/catppuccin-gtk ]; then
        rm -rf /tmp/catppuccin-gtk
    fi

    git clone --depth=1 https://github.com/catppuccin/gtk.git /tmp/catppuccin-gtk

    if [ -d /tmp/catppuccin-gtk ]; then
        cd /tmp/catppuccin-gtk

        # Install dependencies for building
        sudo apt install -y sassc

        # Build and install Mocha variant with Mauve accent
        python3 install.py mocha mauve --dest "$THEME_DIR"

        cd "$SCRIPT_DIR"
        rm -rf /tmp/catppuccin-gtk

        print_info "Catppuccin Mocha GTK theme installed"
    else
        print_warning "Failed to clone Catppuccin GTK theme, skipping..."
    fi
else
    print_info "Catppuccin Mocha GTK theme already installed, skipping..."
fi

# Install Starship prompt
print_info "Installing Starship prompt..."
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    print_info "Starship installed successfully"
else
    print_info "Starship already installed, skipping..."
fi

# Create necessary directories
print_info "Creating necessary directories..."
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/.config"

# Backup existing configs
print_info "Backing up existing configurations..."
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

for file in .zshrc .zprofile .zshenv; do
    if [ -f "$HOME/$file" ]; then
        print_warning "Backing up existing $file to $BACKUP_DIR"
        mv "$HOME/$file" "$BACKUP_DIR/"
    fi
done

for dir in sway nvim qutebrowser htop kitty gtk-3.0 gtk-4.0; do
    if [ -d "$HOME/.config/$dir" ]; then
        print_warning "Backing up existing .config/$dir to $BACKUP_DIR"
        mv "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

# Copy dotfiles
print_info "Installing dotfiles..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$SCRIPT_DIR/.zshrc" "$HOME/"
cp "$SCRIPT_DIR/.zprofile" "$HOME/"
cp "$SCRIPT_DIR/.zshenv" "$HOME/"

cp -r "$SCRIPT_DIR/.config"/* "$HOME/.config/"

# Make scripts executable
chmod +x "$HOME/.config/sway/scripts/"*.sh

# Configure GTK theme using gsettings for GNOME applications
print_info "Configuring GTK theme and dark mode preference..."
gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-mauve-standard+default'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
print_info "GTK theme set to Catppuccin Mocha with dark mode"

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
    print_info "Default shell changed to zsh. You'll need to log out and back in for this to take effect."
fi

# Configure system power button handling
print_info "Configuring power button to use Sway instead of systemd..."
sudo mkdir -p /etc/systemd/logind.conf.d
sudo cp "$SCRIPT_DIR/etc/systemd/logind.conf.d/power-button.conf" /etc/systemd/logind.conf.d/
print_info "Power button will now open power menu instead of shutting down immediately"

# Configure WiFi and Bluetooth
print_info "Enabling and starting system services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

# Restart logind to apply power button configuration
print_info "Restarting systemd-logind to apply power button configuration..."
sudo systemctl restart systemd-logind

echo ""
echo "=========================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Log out and log back in"
echo "2. Start Sway by running: sway"
echo "3. If you want Sway to start automatically on login, add this to your .zprofile:"
echo "   if [ -z \"\$WAYLAND_DISPLAY\" ] && [ \"\$XDG_VTNR\" -eq 1 ]; then"
echo "     exec sway"
echo "   fi"
echo ""
echo "Key bindings:"
echo "  Alt+Return     - Open terminal (kitty)"
echo "  Alt+d          - Application launcher (wofi)"
echo "  Alt+Shift+q    - Close window"
echo "  Alt+Shift+c    - Reload Sway config"
echo "  Alt+Shift+e    - Power menu (wofi)"
echo "  Alt+p          - Screenshot mode"
echo ""
echo "Note: Your old configs have been backed up to: $BACKUP_DIR"
echo ""
