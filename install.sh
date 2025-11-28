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
    foot \
    zsh \
    git \
    curl \
    wget

print_info "Installing application launcher and utilities..."
sudo apt install -y \
    tofi \
    qutebrowser \
    ranger \
    neovim \
    htop

print_info "Installing system utilities..."
sudo apt install -y \
    brightnessctl \
    alsa-utils \
    bluez \
    iwd \
    systemd

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

# Install a Nerd Font for icons
print_info "Installing Nerd Fonts for terminal icons..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
    print_info "Downloading MesloLGS Nerd Font..."
    cd /tmp
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    mv "MesloLGS NF"*.ttf "$FONT_DIR/"
    fc-cache -f
    print_info "Nerd Font installed successfully"
else
    print_info "Nerd Font already installed, skipping..."
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
else
    print_info "Oh My Zsh already installed, skipping..."
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    print_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
    print_info "Powerlevel10k already installed, skipping..."
fi

# Create necessary directories
print_info "Creating necessary directories..."
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.zsh_custom"

# Backup existing configs
print_info "Backing up existing configurations..."
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

for file in .zshrc .zprofile .zshenv .p10k.zsh; do
    if [ -f "$HOME/$file" ]; then
        print_warning "Backing up existing $file to $BACKUP_DIR"
        mv "$HOME/$file" "$BACKUP_DIR/"
    fi
done

for dir in sway foot nvim ranger qutebrowser tofi htop; do
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
cp "$SCRIPT_DIR/.p10k.zsh" "$HOME/"

cp -r "$SCRIPT_DIR/.config"/* "$HOME/.config/"

# Make scripts executable
chmod +x "$HOME/.config/sway/scripts/"*.sh

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
    print_info "Default shell changed to zsh. You'll need to log out and back in for this to take effect."
fi

# Install Neovim plugins
print_info "Installing Neovim plugins..."
if command -v nvim &> /dev/null; then
    print_info "Neovim will install plugins on first launch. This is normal."
fi

# Install ranger devicons plugin (already included in dotfiles)
print_info "Ranger devicons plugin is included in the dotfiles."

# Configure WiFi and Bluetooth
print_info "Enabling and starting system services..."
sudo systemctl enable --now iwd
sudo systemctl enable --now bluetooth

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
echo "  Alt+Return     - Open terminal (foot)"
echo "  Alt+d          - Application launcher (tofi)"
echo "  Alt+Shift+q    - Close window"
echo "  Alt+Shift+c    - Reload Sway config"
echo "  Alt+Shift+e    - Power menu"
echo "  Alt+p          - Screenshot mode"
echo ""
echo "Note: Your old configs have been backed up to: $BACKUP_DIR"
echo ""
