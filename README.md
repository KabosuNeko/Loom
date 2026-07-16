# Loom

<p><br/></p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/23a0ea7d-eb38-4402-b57d-e5ea6f492a1a" alt="Kumin Logo" style="width: 192px" />
</p>
<p><br/></p>

**A suckless setup that isn't suckmore.**

My personal suckless builds and dwm dots files. This setup is built around **dwm** (dynamic window manager), focusing on minimalism, performance, and a cozy aesthetic.

## Preview

| <img width="1920" height="1080" alt="screenshot_1" src="https://github.com/user-attachments/assets/9ffa1cbd-820e-4aaf-8a76-80aba0d617e4" /> | <img width="1920" height="1080" alt="screenshot_2" src="https://github.com/user-attachments/assets/6a85d096-e507-4301-9988-163abfd27734" /> |
|---|---|
| <img width="1920" height="1080" alt="screenshot_3" src="https://github.com/user-attachments/assets/49c13686-ee43-41c5-971a-6442aa56e6a1" /> | <img width="1920" height="1080" alt="screenshot_4" src="https://github.com/user-attachments/assets/a0c17f27-5fdf-4576-a449-7c31a1f07bcf" /> |

## Quick Start

```bash
# Clone the repo
git clone https://github.com/KabosuNeko/Loom.git
cd Loom

# Run the installer (reads pkg.txt for dependencies)
./install.sh
```

The script automates everything:
1. Installs xlibre and all dependencies from `pkg.txt` (official repo + AUR via yay)
2. Copies dotfiles to `~/.config`, `~/.local/bin`
3. Builds and installs `dwm`,`dmenu`, `slstatus`, `st`, `slock` from source

Start your session with `startx` to launch dwm.

## Manual Setup

If you prefer to install step by step:

## XLibre (Official Repository)

XLibre provides additional packages used in this setup.

```bash
# Download and add the signing key
curl -O https://xlibre-arch.github.io/xlibre-archlinux.asc
sudo pacman-key --add xlibre-archlinux.asc
sudo pacman-key --finger B97F7C613F359424
sudo pacman-key --lsign-key B97F7C613F359424

# Add repository entry to /etc/pacman.conf
# Append the following lines:
# [xlibre]
# Server = https://packages.xlibre.net/arch/stable/$arch

# Update and install
sudo pacman -Syyu
sudo pacman -S xlibre-meta
```

### Dependencies

```bash
# Install all packages (yay handles both official + AUR)
yay -S --needed $(grep -v '^#' pkg.txt | grep -v '^$' | tr '\n' ' ')
```

All dependencies are listed in [`pkg.txt`](pkg.txt).

### Dotfiles & Build

```bash
# Copy configs
cp -r home/.config/* ~/.config/
cp -r home/.local/* ~/.local/
cp .xinitrc ~/.xinitrc

# Build suckless tools
for tool in dwm dmenu slstatus st slock; do
    sudo make -C "Suckless/$tool" clean install
done
```

## Patches

### dwm
| Patch | Description |
|---|---|
| **vanitygaps** | 13 layouts (tile, bstack, bstackhoriz, grid, nrowgrid, horizgrid, gaplessgrid, spiral, dwindle, deck, centeredmaster, centeredfloatingmaster) + gap controls |
| **cfact** | Per-client factor adjustment (Shift+H/L/O) |
| **movestack** | Move clients in stack (Shift+J/K) |
| **xrdb** | Reload X resources (Super+F5) |
| **warp** | Focus warp to client on switch |
| **attachaside** | New clients attach to stack side instead of master |
| **actualfullscreen** | Real fullscreen |
| **systray** | System tray |

### st
| Patch | Description |
|---|---|
| **anysize** | Center content when window doesn't match cell size |
| **alpha** | Transparency (opacity 0.8) |
| **boxdraw** | Render box-drawing characters without font |
| **harfbuzz** | Ligature support |
| **graphics/kitty** | Kitty image protocol (view images in terminal) |
| **scrollback** | Scroll back (Shift+PageUp/Down) |
| **externalpipe** | Pipe terminal content to external command (Ctrl+Shift+F9) |
| **clipboard** | Copy/paste clipboard (Ctrl+Shift+C/V) |
| **blink** | Blinking text support |
| **synchronized updates** | Synchronized terminal updates |

### dmenu
| Patch | Description |
|---|---|
| **center** | Center on screen |
| **xresources** | Load colors from X resources |
| **mouse support** | Basic mouse support |
| **alpha** | Transparency (opacity 0.8) |

### slstatus
| Feature | Description |
|---|---|
| **status2d colors** | `^C#[HEX]^`/`^d^` format in status bar |

### slock
Vanilla — no patches, only basic color config.

## Keybindings (Highlights)

| Key Combination | Action |
| --------------- | ------ |
| `Super + Enter` | Open Terminal (st) |
| `Super + D`     | Open Launcher (dmenu) |
| `Super + Q`     | Close Window |
| `Super + Shift + Q` | Quit dwm |
| `Super + S`     | Take Screenshot |
| `Super + Shift + S`     | Take Screenshot (fullscreen) |
| `Super + Shift + R`     | Screen recorder |
| `Super + B`     | Open Bookmarks (dmenu) |
| `Super + R`     | Open Projects (dmenu) |
| `Super + O`     | Tmux Sessions (dmenu) |
| `Super + F`     | Fullscreen |
| `Alt + W`       | Wallpaper Picker |

---

## Additional Configurations

If you are looking to add more configurations or expand your setup, you can check out my other specific config repositories here:

- [MPV](https://github.com/KabosuNeko/mpv-config)
- [FireFox Config](https://github.com/KabosuNeko/YuzuFox/tree/main)
- [Wallpapers](https://github.com/KabosuNeko/Wallpapers)
