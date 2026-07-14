#!/bin/bash

KUMIN_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_FIREFOX="$KUMIN_DIR/firefox/chrome"
FIREFOX_DIR="$HOME/.config/mozilla/firefox"

read -p "===> Do you want to install Firefox custom CSS now? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    if [ -d "$FIREFOX_DIR" ]; then
        shopt -s nullglob
        PROFILES=("$FIREFOX_DIR"/*.default*)
        shopt -u nullglob

        if [ ${#PROFILES[@]} -eq 0 ]; then
            echo "!!! No profiles found."
            echo "!!! Please open firefox for the first time to create the profile"
        else
            for profile_dir in "${PROFILES[@]}"; do
                if [ -d "$profile_dir" ]; then
                    profile_name=$(basename "$profile_dir")
                    echo "[+] Found Firefox profile: $profile_name"
                    
                    mkdir -p "$profile_dir/chrome"
                    if [ -d "$SOURCE_FIREFOX" ]; then
                        cp -rf "$SOURCE_FIREFOX"/* "$profile_dir/chrome/"
                        echo ":: Copied userChrome.css to $profile_name"
                    else
                        echo "!!! Source directory $SOURCE_FIREFOX not found. Skipping CSS copy."
                    fi
                    
                    USER_JS="$profile_dir/user.js"
                    if ! grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$USER_JS" 2>/dev/null; then
                        echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$USER_JS"
                        echo ":: Enabled legacy custom stylesheets for $profile_name"
                    else
                        echo ":: Custom stylesheets already enabled for $profile_name"
                    fi
                fi
            done
        fi
    else
        echo "!!! Firefox directory not found at $FIREFOX_DIR."
        echo "!!! Please open firefox for the first time to create the profile"
    fi
else
    echo "Skipping Firefox CSS installation."
fi
