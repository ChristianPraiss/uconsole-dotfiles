# Quick Installation Guide

## For uConsole with Debian Trixie Lite

### Step 1: Clone the Repository

```bash
cd ~
git clone <your-repo-url> uconsole-dotfiles
cd uconsole-dotfiles
```

### Step 2: Run the Installation Script

```bash
chmod +x install.sh
./install.sh
```

The script will:
- Install all required packages via apt
- Install fonts
- Back up existing configs to `~/.dotfiles_backup_<timestamp>`
- Copy all dotfiles to your home directory
- Enable system services (NetworkManager, Bluetooth)
- Change your default shell to zsh

### Step 3: Log Out and Back In

```bash
logout
```

Or reboot:

```bash
sudo reboot
```

### Step 4: Start Sway

After logging back in:

```bash
sway
```

### Step 5: (Optional) Auto-start Sway on Login

If you want Sway to start automatically when you log in to TTY1, add this to your `~/.zprofile`:

```bash
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec sway
fi
```

## What Gets Installed

### System Packages (via apt)
- **Sway ecosystem**: sway, swayidle, swaylock, swaybg, wl-clipboard
- **Terminal**: foot, zsh
- **Applications**: wofi, qutebrowser, ranger, neovim, htop
- **Utilities**: brightnessctl, alsa-utils, bluez, network-manager, grim, slurp, jq, git
- **Fonts**: fonts-terminus, fonts-font-awesome, fonts-noto

### Additional Installations
- **Grimshot** - Screenshot utility for Sway
- **JetBrainsMono Nerd Font** - Font with icon support
- **Departure Mono** - Monospace font
- **Starship** - Cross-shell prompt

### Dotfiles Installed
- Shell config: `.zshrc`, `.zprofile`, `.zshenv`
- Sway config: `.config/sway/`
- App configs: `.config/foot/`, `.config/nvim/`, `.config/ranger/`, `.config/kitty/`, etc.

## Disk Space Requirements

Approximate disk space needed:
- Base packages: ~500 MB
- Fonts: ~50 MB
- Neovim plugins (installed on first run): ~100 MB

**Total: ~650 MB** (excluding Neovim plugins)

## First Launch Checklist

After installation and starting Sway for the first time:

1. ✅ Test terminal: Press `Alt+Return`
2. ✅ Test app launcher: Press `Alt+d`
3. ✅ Check status bar for battery, WiFi, time
4. ✅ Test brightness: Press `XF86MonBrightnessUp`/`Down` (Fn+brightness keys)
5. ✅ Test volume: Press `XF86AudioRaiseVolume`/`LowerVolume` (Fn+volume keys)
6. ✅ Take a screenshot: Press `Alt+p`, then `s`
7. ✅ Open Neovim to trigger plugin installation: `nvim` (wait for plugins to install)

## Troubleshooting

### "command not found: sway"

The package didn't install. Try:
```bash
sudo apt update
sudo apt install sway
```

### Black screen after starting Sway

Check the logs:
```bash
cat ~/.local/share/sway/sway.log
```

Or run with debug output:
```bash
sway -d 2>&1 | tee sway-debug.log
```

### Status bar shows wrong battery/brightness info or WiFi not showing

The paths might be different on your system. Edit:
```bash
nano ~/.config/sway/scripts/swaybar.sh
```

And check the paths:
- Battery: `/sys/class/power_supply/axp20x-battery/`
- Brightness: `/sys/class/backlight/backlight@0/`

For WiFi status, make sure NetworkManager is running:
```bash
sudo systemctl status NetworkManager
nmcli general status
```

### WiFi not working

Enable and start NetworkManager service:
```bash
sudo systemctl enable --now NetworkManager
```

Connect to WiFi using nmcli or nmtui:
```bash
# Interactive text UI (easier)
nmtui

# Or command line
nmcli device wifi list
nmcli device wifi connect "YourNetworkName" password "YourPassword"
```

### Shell didn't change to zsh

Manually change it:
```bash
chsh -s $(which zsh)
```

Then log out and back in.

### Volume keys not working

The uConsole volume keys should work with the XF86Audio keycodes. If they're not working:

1. Test if ALSA detects your keys:
```bash
# Install alsa-utils if not already installed
sudo apt install alsa-utils

# Test volume control manually
amixer set Master 5%+
amixer set Master 5%-
```

2. If manual commands work but keys don't, the keys might not be mapped correctly. Install `wev` to check what keys are being sent:
```bash
sudo apt install wev
wev  # Press your volume keys and check output
```

3. If the keys show different codes, update `.config/sway/config.d/media` with the correct key codes.

4. Make sure your audio device is not muted:
```bash
amixer sget Master
# Look for [on] or [off] in the output
```

## Rolling Back

If you want to restore your old configuration:

```bash
# Your old configs are backed up to:
ls -la ~/.dotfiles_backup_*

# To restore (replace timestamp with your backup):
cp -r ~/.dotfiles_backup_20250101_120000/* ~/
```

## Getting Help

- Check the main [README.md](README.md) for detailed documentation
- Review Sway wiki: https://github.com/swaywm/sway/wiki
- Check `.config/sway/config` for all key bindings

## Next Steps

1. Customize the wallpaper (see README.md)
2. Configure qutebrowser to your liking
3. Set up your development environment in Neovim
4. Explore Ranger for file management (`ranger` command)
5. Customize your Powerlevel10k prompt (`p10k configure`)
