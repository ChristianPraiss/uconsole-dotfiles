#!/bin/bash

set -e

echo "=========================================="
echo "uConsole Dotfiles Update Script"
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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup existing configs
print_info "Backing up existing configurations..."
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_count=0

# Backup shell configs
for file in .zshrc .zprofile .zshenv; do
    if [ -f "$HOME/$file" ]; then
        print_info "Backing up $file"
        cp "$HOME/$file" "$BACKUP_DIR/"
        ((backup_count++))
    fi
done

# Backup .config directories
for dir in sway foot nvim ranger qutebrowser htop kitty; do
    if [ -d "$HOME/.config/$dir" ]; then
        print_info "Backing up .config/$dir"
        mkdir -p "$BACKUP_DIR/.config"
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/.config/"
        ((backup_count++))
    fi
done

if [ $backup_count -eq 0 ]; then
    print_info "No existing configs found to backup"
    rm -rf "$BACKUP_DIR"
else
    print_info "Backed up $backup_count items to $BACKUP_DIR"
fi

# Copy dotfiles
print_info "Updating dotfiles..."

# Copy shell configs
for file in .zshrc .zprofile .zshenv; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        cp "$SCRIPT_DIR/$file" "$HOME/"
        print_info "Updated $file"
    fi
done

# Copy .config directory
if [ -d "$SCRIPT_DIR/.config" ]; then
    mkdir -p "$HOME/.config"

    # Copy each subdirectory individually
    for dir in "$SCRIPT_DIR/.config"/*; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            cp -r "$dir" "$HOME/.config/"
            print_info "Updated .config/$dirname"
        fi
    done
fi

# Make scripts executable
if [ -d "$HOME/.config/sway/scripts" ]; then
    chmod +x "$HOME/.config/sway/scripts/"*.sh
    print_info "Made Sway scripts executable"
fi

# Reload Sway if it's running
if pgrep -x "sway" > /dev/null; then
    print_info "Sway is running. Reload config with Alt+Shift+c"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Update Complete!${NC}"
echo "=========================================="
echo ""

if [ $backup_count -gt 0 ]; then
    echo "Your previous configs have been backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
fi

echo "Changes applied:"
echo "  ✓ Shell configuration (.zshrc, .zprofile, .zshenv)"
echo "  ✓ Sway configuration"
echo "  ✓ Application configs (foot, nvim, ranger, kitty, etc.)"
echo ""

if pgrep -x "sway" > /dev/null; then
    echo "To apply Sway changes:"
    echo "  - Press Alt+Shift+c to reload Sway config"
    echo ""
fi

echo "For shell changes to take effect:"
echo "  - Open a new terminal, or"
echo "  - Run: source ~/.zshrc"
echo ""
