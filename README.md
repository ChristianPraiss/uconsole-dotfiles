# uConsole Dotfiles

Dotfiles configuration for ClockworkPi uConsole running Debian Trixie Lite with Sway (Wayland compositor).

## Overview

This configuration provides a minimal, keyboard-focused environment optimized for the uConsole's small screen and unique form factor.

### Included Configurations

- **Sway** - Tiling Wayland compositor with uConsole-specific settings
- **Foot** - Fast, lightweight terminal emulator
- **Tofi** - Application launcher
- **Neovim** - LazyVim-based editor configuration
- **Qutebrowser** - Keyboard-driven web browser
- **Ranger** - Terminal file manager with devicons
- **Zsh** - Shell with Oh My Zsh and Powerlevel10k theme
- **htop** - System monitor

### Key Features

- Portrait mode display (90° rotation for DSI-1)
- Custom status bar showing battery, volume, brightness, WiFi, Bluetooth, time
- Tabbed workspace layout by default
- Gruvbox color scheme throughout
- Optimized for keyboard-only workflow
- Power management with auto-sleep after 60 seconds

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
2. Set up Oh My Zsh with Powerlevel10k theme
3. Install Nerd Fonts for icon support
4. Back up your existing configurations
5. Copy dotfiles to your home directory
6. Configure system services (WiFi, Bluetooth)
7. Change your default shell to zsh

### Manual Installation

If you prefer to install manually or customize the process:

#### 1. Install Required Packages

```bash
sudo apt update
sudo apt install -y \
    sway swayidle swaylock swaybg \
    foot zsh git curl wget \
    tofi qutebrowser ranger neovim htop \
    brightnessctl alsa-utils bluez iwd \
    grim slurp jq wl-clipboard \
    fonts-terminus fonts-font-awesome fonts-noto
```

#### 2. Install Oh My Zsh and Powerlevel10k

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ~/.oh-my-zsh/custom/themes/powerlevel10k
```

#### 3. Install Nerd Fonts

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fc-cache -f
```

#### 4. Copy Dotfiles

```bash
cp .zshrc .zprofile .zshenv .p10k.zsh ~/
cp -r .config/* ~/.config/
chmod +x ~/.config/sway/scripts/*.sh
```

#### 5. Set Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

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
| `Alt+d` | Application launcher (tofi) |
| `Alt+Shift+q` | Kill focused window |
| `Alt+Shift+c` | Reload Sway configuration |
| `Alt+Shift+e` | Power menu (shutdown/restart/logout) |

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

- Bluetooth status
- WiFi status
- Screen brightness level
- Volume level
- Battery percentage and charging status
- Date and time

The status bar script is located at `.config/sway/scripts/swaybar.sh`

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
- `.p10k.zsh` - Powerlevel10k theme configuration

### Applications

- Neovim: `.config/nvim/` (LazyVim-based setup)
- Foot terminal: `.config/foot/foot.ini`
- Ranger: `.config/ranger/rc.conf`
- Qutebrowser: `.config/qutebrowser/config.py`
- Tofi launcher: `.config/tofi/config`
- htop: `.config/htop/htoprc`

## Customization

### Changing the Wallpaper

Edit `.config/sway/config` and modify line 25:

```
output * bg $HOME/.config/sway/tsutsugou.png center #111111
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

The status bar relies on uConsole-specific hardware paths:

- Battery: `/sys/class/power_supply/axp20x-battery/`
- Brightness: `/sys/class/backlight/backlight@0/`

If these paths differ on your system, edit `.config/sway/scripts/swaybar.sh`

### WiFi or Bluetooth Not Working

Enable the services:

```bash
sudo systemctl enable --now iwd
sudo systemctl enable --now bluetooth
```

### Icons Not Showing in Terminal

Make sure you installed a Nerd Font and it's being used by your terminal. For foot, check `.config/foot/foot.ini`

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
- tofi
- qutebrowser
- ranger
- neovim
- htop
- brightnessctl
- alsa-utils
- bluez
- iwd
- grim, slurp, jq
- wl-clipboard

### Optional Packages

- fonts-terminus
- fonts-font-awesome
- fonts-noto
- A Nerd Font (MesloLGS recommended)

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
- Neovim setup based on [LazyVim](https://www.lazyvim.org/)
- Powerlevel10k theme by [romkatv](https://github.com/romkatv/powerlevel10k)
- Ranger devicons plugin

## Contributing

Suggestions and improvements are welcome! This is optimized for the ClockworkPi uConsole but should work on other ARM devices with minor modifications.
