# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dotfiles configuration repository for the ClockworkPi uConsole running Debian Trixie Lite with Sway (Wayland compositor). The project provides a modular installation system with an interactive TUI built using whiptail.

## Installation System Architecture

### Modular Design

The installer follows a modular architecture where each component is an independent, self-contained module:

- **Main Script**: `install.sh` - Interactive TUI installer using whiptail
- **Modules**: `modules/XX-name.sh` - Individual installation modules numbered for dependency order (00-11)
- **Libraries**: `lib/*.sh` - Shared utilities sourced by modules and main installer

**Critical**: Module scripts assume libraries are already sourced by the caller (install.sh). Never source libraries within modules. Libraries are sourced once at the top level in install.sh:
```bash
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/package-manager.sh"
source "$SCRIPT_DIR/lib/backup.sh"
source "$SCRIPT_DIR/lib/state.sh"
```

### Module Structure

Each module in `modules/` must follow this standard structure:

```bash
#!/bin/bash
#
# Module: [Name]
# Description: [Description]
# Dependencies: [comma-separated list or none]
#
# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="module-id"           # Used in file naming (XX-module-id.sh)
MODULE_NAME="Friendly Name"      # Displayed in TUI
MODULE_DESCRIPTION="Short desc"
MODULE_DEPENDENCIES=()           # Array of module IDs this depends on

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."
    # Installation logic here
    return 0  # or 1 on failure
}

# Check if module is already installed
check_installed() {
    # Return 0 if installed, 1 if not
}

# Estimate installation time (seconds)
estimate_time() {
    echo "120"  # Return seconds as string
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
```

### Module Execution Order

Modules are numbered to enforce dependency order:
0. `00-system-tweaks.sh` - System optimization (quiet console, disable cloud-init)
1. `01-sway-core.sh` - Core Sway/Wayland system (no dependencies)
2. `02-audio.sh` - PipeWire audio stack
3. `03-terminal-shell.sh` - Kitty, Zsh, Starship
4. `04-applications.sh` - Wofi, Qutebrowser, Neovim, Nautilus, htop
5. `05-screenshots.sh` - Grim, Slurp, Grimshot
6. `06-fonts.sh` - Nerd Fonts installation
7. `07-gtk-theme.sh` - Catppuccin Mocha GTK theme
8. `08-dotfiles.sh` - Deploy dotfiles to home directory
9. `09-services.sh` - Enable NetworkManager, Bluetooth
10. `10-notifications.sh` - SwayNC notification center with Catppuccin
11. `11-greetd.sh` - greetd display manager with tuigreet TUI greeter

The installer resolves and executes modules in this fixed order regardless of selection order.

### Library Functions

**Common utilities** (`lib/common.sh`):
- `print_info()`, `print_error()`, `print_warning()`, `print_success()` - Colored output
- `check_command()` - Check if command exists
- `check_root()` - Verify not running as root

**Package management** (`lib/package-manager.sh`):
- `apt_update()` - Update package lists (cached per session)
- `apt_install package1 package2 ...` - Install packages with error handling
- `apt_check_installed package` - Check if package is installed

**State management** (`lib/state.sh`):
- `init_state()` - Initialize state tracking in `.install-state/`
- `mark_completed module_id` - Mark module as completed
- `mark_failed module_id error_msg` - Mark module as failed
- `is_completed module_id` - Check if module already completed
- `log_message level message` - Write to install log

**Backup utilities** (`lib/backup.sh`):
- Functions for backing up existing configurations before deployment

### State Tracking

Installation state is tracked in `.install-state/`:
- `completed.txt` - List of successfully installed modules
- `failed.txt` - List of failed modules
- `install.log` - Detailed installation log with timestamps

The installer can resume interrupted installations and skip already-completed modules.

## Hardware-Specific Configuration

### uConsole Hardware Details

The dotfiles are tailored for uConsole hardware:

**Display**: DSI-1 rotated 90° for portrait mode
```bash
output DSI-1 transform 90
```

**Battery**: AXP209 power management chip
- Path: `/sys/class/power_supply/axp20x-battery/`

**Backlight**: Custom backlight driver
- Path: `/sys/class/backlight/backlight@0/`

**Status Bar Script** (`.config/sway/scripts/swaybar.sh`):
- Reads hardware-specific paths for battery, brightness
- Uses `nmcli` for WiFi status (requires NetworkManager)
- Uses `hciconfig` for Bluetooth status
- Uses `wpctl` for audio volume (requires PipeWire)

## Sway Configuration

### Configuration Structure

Main config: `.config/sway/config`
- Modular includes from `.config/sway/config.d/`:
  - `navigation` - Window/workspace navigation
  - `media` - Volume/brightness controls
  - `screenshot` - Screenshot mode bindings
  - `statusbar` - Status bar configuration

### Key Design Decisions

- **Layout**: Default workspace layout is `tabbed` (optimized for small screen)
- **Font**: JetBrainsMono Nerd Font Bold 18
- **Mod Key**: Alt key (Mod1) - not Super/Windows key
- **Idle Timeout**: 60 seconds before screen off (power management for battery)
- **Power Button**: Opens power menu (safer than instant shutdown)

## Development Commands

### Testing Installation

Run the interactive installer:
```bash
./install.sh
```

The TUI will guide through component selection and handle errors/resume automatically.

### Updating Existing Dotfiles

When dotfiles have been updated but packages don't need reinstallation, there should be an `update.sh` script that:
- Backs up current configs
- Copies new dotfiles
- Makes scripts executable
- Skips package installation

### Testing Individual Modules

Modules cannot be run directly. To test a module:
1. Create a test script that sources the necessary libraries
2. Source the module
3. Call the module functions

### Reloading Sway Config

After modifying Sway configuration:
- Press `Alt+Shift+c` to reload without restarting

### Checking Logs

View installation logs:
```bash
cat .install-state/install.log
```

## Display Manager (greetd)

Module 11 installs and configures greetd display manager with tuigreet:

**Why greetd?** Minimal, Rust-based display manager designed specifically for Wayland compositors like Sway. Unlike SDDM, it doesn't pull in KDE/Qt dependencies.

**Greeter**: tuigreet - Terminal UI greeter
- Minimal resource usage (ideal for battery-powered uConsole)
- Shows time, remembers last user and session
- Native Wayland support

**Configuration** (`/etc/greetd/config.toml`):
- Default command: `tuigreet --time --remember --remember-session --cmd sway`
- Runs on VT1
- User: `greeter`

**Important**: greetd service is enabled but not started during installation (to avoid killing the current session). A reboot is required after installation.

## Color Scheme

The configuration uses Catppuccin color scheme throughout:
- Sway window borders: Catppuccin Mocha colors
- GTK Theme: Catppuccin Mocha (module 07)
- Login Screen: tuigreet TUI (module 11)
- Notifications: Catppuccin Mocha (module 10)
- Wallpaper: ClockworkPi logo on dark background

## Common Pitfalls

1. **Don't source libraries in modules** - Libraries are sourced by install.sh before modules are loaded
2. **Module numbering matters** - Number determines execution order, not selection order
3. **apt_update is cached** - Calling `apt_install` automatically runs `apt_update` once per session
4. **Always use absolute paths** - When deploying dotfiles, use `$HOME` or full paths
5. **NetworkManager dependency** - WiFi status in status bar requires NetworkManager running
6. **Hardware paths** - Battery/brightness paths are uConsole-specific, may need adjustment for other devices
