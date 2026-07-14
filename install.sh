#!/usr/bin/env bash
# Loom - Automated Install Script
set -euo pipefail

DOTDIR="$(dirname "$(realpath "$0")")"
PKGLIST="$DOTDIR/pkg.txt"
AUR_HELPER="yay-bin"

[ -f "$PKGLIST" ] || { echo "XXX [ERROR] pkg.txt not found"; exit 1; }

# ─── Install XLibre (official method) ─────────────────────────────────────
read -p "===> Install XLibre (official repository)? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    echo "==> Adding XLibre signing key..."
    if ! curl -O https://xlibre-arch.github.io/xlibre-archlinux.asc; then
        echo "XXX [ERROR] Failed to download XLibre signing key." >&2
        exit 1
    fi
    sudo pacman-key --add xlibre-archlinux.asc
    sudo pacman-key --finger B97F7C613F359424
    sudo pacman-key --lsign-key B97F7C613F359424
    rm -f xlibre-archlinux.asc

    echo "==> Adding XLibre repository to /etc/pacman.conf..."
    if ! grep -q '\[xlibre\]' /etc/pacman.conf; then
        sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

[xlibre]
Server = https://packages.xlibre.net/arch/stable/$arch
EOF
    else
        echo ":: [xlibre] already in /etc/pacman.conf — skipping."
    fi

    echo "==> Updating and installing xlibre-meta..."
    sudo pacman -Syyu --noconfirm
    sudo pacman -S --noconfirm xlibre-meta
else
    echo ":: Skipping XLibre installation."
fi

# ─── Install yay (AUR helper) ─────────────────────────────────────────────
read -p "===> Install $AUR_HELPER (AUR helper)? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    sudo pacman -S --needed --noconfirm git base-devel
    if ! git clone "https://aur.archlinux.org/$AUR_HELPER.git" /tmp/yay; then
        echo "XXX [ERROR] Failed to clone $AUR_HELPER repository." >&2
        exit 1
    fi
    if ! (cd /tmp/yay && makepkg -si --noconfirm); then
        echo "XXX [ERROR] makepkg failed to build/install $AUR_HELPER." >&2
        exit 1
    fi
    rm -rf /tmp/yay
else
    echo ":: Skipping $AUR_HELPER installation."
fi

# ─── Install all packages via yay ─────────────────────────────────────────
if command -v yay >/dev/null 2>&1; then
    read -p "===> Install all packages from pkg.txt via yay? (y/n): " confirm
    if [[ $confirm == [yY] ]]; then
        pkgs="$(grep -v '^#' "$PKGLIST" | grep -v '^$' | tr '\n' ' ')"
        set -- $pkgs
        if [ $# -gt 0 ]; then
            yay -S --needed --noconfirm "$@"
        fi
    else
        echo ":: Skipping package installation."
    fi
else
    echo ":: yay not found — skipping package installation."
fi

# ─── Install dotfiles ────────────────────────────────────────────────────
read -p "===> Install dotfiles? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    echo "==> Installing dotfiles..."
    mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/Pictures"
    cp -r "$DOTDIR/home/.config/"* "$HOME/.config/" 2>/dev/null || true
    cp -r "$DOTDIR/home/.local/bin/"* "$HOME/.local/bin/" 2>/dev/null || true
    cp "$DOTDIR/.xinitrc" "$HOME/.xinitrc" 2>/dev/null || true
    cp "$DOTDIR/.xprofile" "$HOME/.xprofile" 2>/dev/null || true
else
    echo ":: Skipping dotfiles installation."
fi

# ─── Wallpapers ────────────────────────────────────────────────────
read -p "===> Download my Wallpapers collections? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    echo "==> Fetching Wallpapers..."
    mkdir -p "$HOME/Pictures"
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

    if [ -d "$WALLPAPER_DIR/.git" ]; then
        echo ":: Wallpapers repository already exists. Pulling latest changes..."
        git -C "$WALLPAPER_DIR" pull
    elif [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
        echo ":: Cloning from https://github.com/KabosuNeko/Wallpapers.git..."
        git clone --depth 1 https://github.com/KabosuNeko/Wallpapers.git "$WALLPAPER_DIR"
    else
        echo ":: Directory $WALLPAPER_DIR already exists and is not empty. Skipping clone."
    fi
else
    echo ":: Skipping Wallpapers clone."
fi

# ─── Install Custom Fonts (Maple Mono NF Unhinted) ───────────────────────
read -p "===> Install Maple Mono NF (Unhinted) manually from GitHub? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    echo "==> Downloading and installing Maple Mono NF Unhinted..."

    sudo pacman -S --needed --noconfirm unzip jq

    FONT_DIR="$HOME/.local/share/fonts/MapleMono"
    mkdir -p "$FONT_DIR"

    echo ":: Fetching latest release link..."
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/subframe7536/Maple-font/releases/latest | jq -r '.assets[] | select(.name == "MapleMono-NF-unhinted.zip") | .browser_download_url')

    if [ -n "$DOWNLOAD_URL" ] && [ "$DOWNLOAD_URL" != "null" ]; then
        echo ":: Downloading MapleMono-NF-unhinted.zip..."
        curl -L "$DOWNLOAD_URL" -o /tmp/MapleMono.zip

        echo ":: Extracting to $FONT_DIR..."
        unzip -o -q /tmp/MapleMono.zip -d "$FONT_DIR"
        rm /tmp/MapleMono.zip

        echo ":: Rebuilding font cache..."
        fc-cache -fv
        echo ":: Maple Mono Unhinted installed successfully."
    else
        echo "XXX [ERROR] Failed to find the download link. Please check GitHub API." >&2
    fi
else
    echo ":: Skipping Maple Mono installation."
fi

# ─── Build suckless tools ────────────────────────────────────────────────
read -p "===> Build and install suckless tools (dwm, slstatus, st, slock, dmenu)? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    echo "==> Building suckless tools..."
    for tool in dwm slstatus st slock dmenu; do
        echo "  -> Building $tool..."
        if ! sudo make -C "$DOTDIR/Suckless/$tool" clean install; then
            echo "XXX [ERROR] Failed to build $tool." >&2
            exit 1
        fi
    done
else
    echo ":: Skipping suckless tools build."
fi

gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

systemctl --user stop pipewire pipewire-pulse wireplumber 2>/dev/null || true

pkill -x pipewire || true
pkill -x pipewire-pulse || true
pkill -x wireplumber || true

rm -rf ~/.local/state/wireplumber ~/.cache/wireplumber

systemctl --user daemon-reload
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

systemctl --user restart pipewire pipewire-pulse wireplumber

echo ""
echo "==> All done!"
echo "    Start X with 'startx' to launch dwm."
