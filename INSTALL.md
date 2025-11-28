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
- Set up Oh My Zsh and Powerlevel10k
- Install fonts
- Back up existing configs to `~/.dotfiles_backup_<timestamp>`
- Copy all dotfiles to your home directory
- Enable system services (WiFi, Bluetooth)
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
- **Applications**: tofi, qutebrowser, ranger, neovim, htop
- **Utilities**: brightnessctl, alsa-utils, bluez, iwd, grim, slurp, jq, git
- **Fonts**: fonts-terminus, fonts-font-awesome, fonts-noto

### Additional Installations
- **Oh My Zsh** - ZSH framework
- **Powerlevel10k** - ZSH theme with pretty icons
- **MesloLGS Nerd Font** - Font with icon support
- **Grimshot** - Screenshot utility for Sway

### Dotfiles Installed
- Shell config: `.zshrc`, `.zprofile`, `.zshenv`, `.p10k.zsh`
- Sway config: `.config/sway/`
- App configs: `.config/foot/`, `.config/nvim/`, `.config/ranger/`, etc.

## Disk Space Requirements

Approximate disk space needed:
- Base packages: ~500 MB
- Fonts: ~50 MB
- Oh My Zsh + Powerlevel10k: ~20 MB
- Neovim plugins (installed on first run): ~100 MB

**Total: ~700 MB** (excluding Neovim plugins)

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

### Status bar shows wrong battery/brightness info

The paths might be different on your system. Edit:
```bash
nano ~/.config/sway/scripts/swaybar.sh
```

And check the paths:
- Battery: `/sys/class/power_supply/axp20x-battery/`
- Brightness: `/sys/class/backlight/backlight@0/`

### WiFi not working

Enable and start iwd service:
```bash
sudo systemctl enable --now iwd
iwctl device list
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect "YourNetworkName"
```

### Shell didn't change to zsh

Manually change it:
```bash
chsh -s $(which zsh)
```

Then log out and back in.

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
