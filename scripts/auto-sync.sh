#!/usr/bin/env bash
set -euo pipefail

# Ensure jq is installed since we need it to safely edit the JSON config
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is required to modify JSON files safely."
    echo "Please install it using your package manager (e.g., sudo pacman -S jq)."
    exit 1
fi

SUDOERS_FILE="/etc/sudoers.d/caelestia-sddm-sync"
CLI_JSON="$HOME/.config/caelestia/cli.json"
HOOK_CMD="sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh --posthook"

enable_autosync() {
    echo ""
    echo "Enabling Auto-Sync..."
    
    # 1. Setup passwordless sudo for the sync script
    echo "-> Setting up passwordless sudo..."
    echo "$USER ALL=(root) NOPASSWD: /usr/share/sddm/themes/caelestia/scripts/sync.sh" | sudo tee "$SUDOERS_FILE" >/dev/null
    sudo chmod 440 "$SUDOERS_FILE"

    # 2. Safely inject posthooks into Caelestia's cli.json
    echo "-> Configuring Caelestia posthooks..."
    mkdir -p "$(dirname "$CLI_JSON")"
    if [ ! -f "$CLI_JSON" ]; then
        echo "{}" > "$CLI_JSON"
    fi

    local tmp_json
    tmp_json=$(mktemp)
    jq --arg cmd "$HOOK_CMD" '.wallpaper.postHook = $cmd | .theme.postHook = $cmd' "$CLI_JSON" > "$tmp_json" && mv "$tmp_json" "$CLI_JSON"
    
    echo "✓ Auto-Sync is now ENABLED. Your lock screen will update automatically."
}

disable_autosync() {
    echo ""
    echo "Disabling Auto-Sync..."
    
    # 1. Remove passwordless sudo rule
    if [ -f "$SUDOERS_FILE" ]; then
        echo "-> Removing passwordless sudo rules..."
        sudo rm -f "$SUDOERS_FILE"
    fi

    # 2. Safely remove posthooks from Caelestia's cli.json
    if [ -f "$CLI_JSON" ]; then
        echo "-> Removing Caelestia posthooks..."
        local tmp_json
        tmp_json=$(mktemp)
        jq 'del(.wallpaper.postHook, .theme.postHook)' "$CLI_JSON" > "$tmp_json" && mv "$tmp_json" "$CLI_JSON"
    fi

    echo "✓ Auto-Sync is now DISABLED."
}

echo "============================================================"
echo "               Caelestia SDDM Auto-Sync Setup               "
echo "============================================================"
echo "1) Enable Auto-Sync  (Updates lock screen on wallpaper change)"
echo "2) Disable Auto-Sync (Removes background hooks and sudo rules)"
echo "3) Exit"
echo "============================================================"
read -r -p "Select an option [1-3]: " choice

case $choice in
    1)
        sudo -v # Prompt for sudo upfront
        enable_autosync
        ;;
    2)
        sudo -v
        disable_autosync
        ;;
    *)
        echo "Exiting."
        exit 0
        ;;
esac
