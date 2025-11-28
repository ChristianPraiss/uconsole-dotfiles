# uConsole Dotfiles

Dotfiles configuration for ClockworkPi uConsole running Debian Trixie Lite with Sway (Wayland compositor).

## Overview

This configuration provides a minimal, keyboard-focused environment optimized for the uConsole's small screen and unique form factor.

### Included Configurations

- **Sway** - Tiling Wayland compositor with uConsole-specific settings
- **Foot** - Fast, lightweight terminal emulator
- **Kitty** - Alternative terminal emulator
- **Wofi** - Application launcher and power menu
- **Neovim** - Custom editor configuration
- **Qutebrowser** - Keyboard-driven web browser
- **Ranger** - Terminal file manager with devicons
- **Zsh** - Minimal shell configuration
- **htop** - System monitor

### Key Features

- Portrait mode display (90° rotation for DSI-1)
- Custom status bar showing battery, volume, brightness, WiFi, Bluetooth, time
- Tabbed workspace layout by default
- Gruvbox color scheme throughout
- Optimized for keyboard-only workflow
- Power management with auto-sleep after 60 seconds
- Safe power button - opens menu instead of instant shutdown

## Installation

### Prerequisites

- ClockworkPi uConsole
- Debian Trixie Lite (or compatible Debian-based system)
- Internet connection
- sudo privileges

### Quick Install

```bash
git clone https://github.com/yourusername/uconsole-dotfiles.git
cd uconsole-dotfiles
chmod +x install.sh
./install.sh
```

The installation script will:

1. Install all required packages
2. Back up your existing configurations
3. Copy dotfiles to your home directory
4. Configure system services (NetworkManager, Bluetooth)
5. Change your default shell to zsh

### Manual Installation

If you prefer to install manually or customize the process:

#### 1. Install Required Packages

```bash
sudo apt update
sudo apt install -y \
    sway swayidle swaylock swaybg \
    foot zsh git curl wget \
    wofi qutebrowser ranger neovim htop \
    brightnessctl alsa-utils bluez network-manager \
    grim slurp jq wl-clipboard \
    fonts-terminus fonts-font-awesome fonts-noto
```

#### 2. Copy Dotfiles

```bash
cp .zshrc .zprofile .zshenv ~/
cp -r .config/* ~/.config/
chmod +x ~/.config/sway/scripts/*.sh
```

#### 3. Set Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

### Updating Dotfiles

If you've already installed everything and just want to update your dotfiles (without reinstalling packages), use the update script:

```bash
cd uconsole-dotfiles
git pull  # Get latest changes from repository
./update.sh
```

The update script will:
- Back up your current configs to `~/.dotfiles_backup_<timestamp>`
- Copy updated dotfiles to your home directory
- Make scripts executable
- Skip all package installation and system configuration

After updating:
- For Sway changes: Press `Alt+Shift+c` to reload
- For shell changes: Open a new terminal or run `source ~/.zshrc`

## Usage

### Starting Sway

After logging in, start Sway with:

```bash
sway
```

To start Sway automatically on login, the install script suggests adding auto-start code to `.zprofile` (you can add this manually if needed).

### Key Bindings

#### Basic Navigation

| Key Binding | Action |
|------------|---------|
| `Alt+Return` | Open terminal (foot) |
| `Alt+d` | Application launcher (wofi) |
| `Alt+Shift+q` | Kill focused window |
| `Alt+Shift+c` | Reload Sway configuration |
| `Alt+Shift+e` | Power menu (wofi - shutdown/restart/logout) |
| `Power Button` | Power menu (safer than instant shutdown) |

#### Window Management

Sway uses tabbed layout by default. See `.config/sway/config.d/navigation` for all navigation bindings.

#### Media Controls

| Key Binding | Action |
|------------|---------|
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86AudioMute` | Mute/unmute |
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |

#### Screenshots

Press `Alt+p` to enter screenshot mode, then:

| Key | Action |
|-----|--------|
| `s` | Save full screen |
| `Ctrl+s` | Copy full screen to clipboard |
| `w` | Save window |
| `Ctrl+w` | Copy window to clipboard |
| `z` | Save selected area |
| `Ctrl+z` | Copy selected area to clipboard |
| `a` | Save active window |
| `o` | Save output |
| `Esc` | Exit screenshot mode |

Screenshots are saved to `~/Pictures/Screenshots/`

### Status Bar

The custom status bar shows:

- Bluetooth status (via `hciconfig`)
- WiFi status (via NetworkManager/`nmcli`)
- Screen brightness level
- Volume level (via `amixer`)
- Battery percentage and charging status
- Date and time

The status bar script is located at `.config/sway/scripts/swaybar.sh`

**Note**: The status bar requires NetworkManager to be running for WiFi status display.

## Configuration Files

### Sway

- Main config: `.config/sway/config`
- Navigation bindings: `.config/sway/config.d/navigation`
- Media controls: `.config/sway/config.d/media`
- Screenshot mode: `.config/sway/config.d/screenshot`
- Status bar: `.config/sway/config.d/statusbar`

### Shell (Zsh)

- `.zshrc` - Main zsh configuration
- `.zshenv` - Environment variables
- `.zprofile` - Login shell configuration

### Applications

- Neovim: `.config/nvim/` - Custom setup
- Foot terminal: `.config/foot/foot.ini`
- Kitty terminal: `.config/kitty/kitty.conf`
- Ranger: `.config/ranger/rc.conf`
- Qutebrowser: `.config/qutebrowser/config.py`
- Starship: `.config/starship.toml` (optional prompt)
- htop: `.config/htop/htoprc`

## Customization

### Changing the Wallpaper

Edit `.config/sway/config` and modify line 25:

```
output * bg $HOME/.config/sway/clockworkpi_logo.png center #111111
```

Replace `tsutsugou.png` with your own image.

### Changing the Color Scheme

The configuration uses Gruvbox colors. To change:

1. Edit `.config/sway/config` (lines 20-21 for window borders)
2. Update Neovim theme in `.config/nvim/lua/plugins/gruvbox.lua`
3. Modify foot terminal colors in `.config/foot/foot.ini`

### Adjusting Auto-Sleep Timeout

Edit `.config/sway/config` line 29-31 to change the idle timeout (currently 60 seconds).

### Font Size

The Sway config uses Terminus Bold 20. To change the font size, edit line 14 in `.config/sway/config`:

```
font Terminus Bold 20
```

## Troubleshooting

### Sway Won't Start

1. Check if you're on a TTY (not in an X session)
2. Verify Sway is installed: `which sway`
3. Check for error messages: `sway -d 2>&1 | tee sway.log`

### Status Bar Not Showing Information

The status bar relies on uConsole-specific hardware paths and system tools:

- Battery: `/sys/class/power_supply/axp20x-battery/`
- Brightness: `/sys/class/backlight/backlight@0/`
- WiFi: Requires NetworkManager (`nmcli` command)
- Bluetooth: Requires `hciconfig` (from bluez-utils or bluez)
- Audio: Requires `amixer` (from alsa-utils)

If hardware paths differ on your system, edit `.config/sway/scripts/swaybar.sh`

If WiFi icon doesn't show:
```bash
# Make sure NetworkManager is running
sudo systemctl status NetworkManager

# Test nmcli command
nmcli radio wifi
nmcli general status
```

### WiFi or Bluetooth Not Working

Enable the services:

```bash
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
```

Connect to WiFi using nmcli or nmtui:

```bash
nmtui  # Text-based UI
# or
nmcli device wifi list
nmcli device wifi connect "YourNetworkName" password "YourPassword"
```

### Neovim Plugins Not Loading

On first launch, LazyVim will automatically install plugins. If this doesn't happen:

```bash
nvim --headless "+Lazy! sync" +qa
```

## Dependencies

### Required Packages

- sway, swayidle, swaylock, swaybg
- foot
- zsh, git, curl, wget
- wofi
- qutebrowser
- ranger
- neovim
- htop
- brightnessctl
- alsa-utils
- bluez
- network-manager
- grim, slurp, jq
- wl-clipboard

### Fonts

The installation script automatically installs:
- JetBrainsMono Nerd Font
- Departure Mono
- fonts-terminus
- fonts-font-awesome
- fonts-noto

### Additional Tools

The installation script also installs:
- **Starship** - Cross-shell prompt (configured via `.config/starship.toml`)

### Optional Packages

- kitty (alternative terminal)

## Hardware-Specific Notes

### uConsole Display

The configuration rotates the DSI-1 display 90° for portrait mode:

```
output DSI-1 transform 90
```

### Power Management

Battery information is read from uConsole's AXP209 power management chip:

```bash
/sys/class/power_supply/axp20x-battery/
```

## License

Feel free to use and modify these dotfiles for your own setup.

## Credits

- Sway configuration inspired by the default Sway config
- Neovim custom configuration
- Ranger devicons plugin

## Contributing

Suggestions and improvements are welcome! This is optimized for the ClockworkPi uConsole but should work on other ARM devices with minor modifications.
