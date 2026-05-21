#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

# == Security & Others ==

header "Security & Others"
if yn "Remove firejail?"; then

     # Remove Firejail
        sudo nala purge firejail firejail-profiles || { err "Failed to remove Firejail, is it installed?"; exit 1; }

    # Remove Folders & Profiles
        sudo rm -rf /etc/firejail || true
        sudo rm -rf ~/.config/firejail || true

    else
    info "Command failed or skipped"
fi

# Remove Additionals
if yn "Remove Additionals?"; then
    clear
    remove_if_installed() {
        local packages=("$@")
        local to_remove=()

        for package in "${packages[@]}"; do
            if dpkg -s "$package" &>/dev/null; then
                to_remove+=("$package")
            else
                info "$package is not installed"
            fi
        done

        if [ ${#to_remove[@]} -eq 0 ]; then
            info "None of the packages are installed."
            return 0
        elif [ ${#to_remove[@]} -eq ${#packages[@]} ]; then
            info "All packages are installed. Removing all..."
        else
            info "Removing only the installed packages..."
        fi
                sudo nala purge "${to_remove[@]}"
        }

remove_if_installed torbrowser-launcher proton-vpn-cli i2pd
else
    info "Skipping..."
fi

# Remove AI Apps (OpenCode, Ollama, Alpaca)
header "AI Apps"
if yn "Remove AI Apps?"; then
        info "Removing AI apps..."

        if command -v opencode &>/dev/null; then
            sudo rm -f "$(command -v opencode)" 2>/dev/null || true
            ok "Removed OpenCode binary."
        fi

        if command -v ollama &>/dev/null; then
            sudo rm -f "$(command -v ollama)" 2>/dev/null || true
            sudo systemctl stop ollama 2>/dev/null || true
            sudo systemctl disable ollama 2>/dev/null || true
            rm -f /etc/systemd/system/ollama.service 2>/dev/null || true
            sudo rm -f /etc/systemd/system/multi-user.target.wants/ollama.service 2>/dev/null || true
            ok "Removed Ollama."
        fi

        if flatpak info com.jeffser.Alpaca &>/dev/null; then
            flatpak remove -y com.jeffser.Alpaca 2>/dev/null || true
            ok "Removed Alpaca."
        fi

        rm -rf ~/.config/opencode 2>/dev/null || true
        rm -rf ~/.ollama 2>/dev/null || true
        ok "Removed AI app configs."

    else
        info "Command Failed or Cancelled"
fi

# Remove GameDev Apps
clear
header "GameDev Apps"
info "Remove GameDev Apps?"
echo "This will remove Godot, LDtk, and Libresprite along with their configs."
echo "Do you want to continue?"
echo "1) Yes, Remove GameDev Apps"
echo "2) No, Skip"

case $(pick "Choice [1-2]:" 1 2) in
      1)
        info "Removing GameDev apps..."

        rm -f "$SCRIPT_DIR"/Godot* 2>/dev/null || true
        rm -f "$SCRIPT_DIR"/LDtk* 2>/dev/null || true
        rm -f "$SCRIPT_DIR"/LibreSprite* 2>/dev/null || true

        rm -rf ~/.config/godot 2>/dev/null || true
        rm -rf ~/.config/ldtk 2>/dev/null || true
        rm -rf ~/.local/share/LibreSprite 2>/dev/null || true
        rm -rf ~/.local/share/libresprite 2>/dev/null || true
        rm -rf ~/.config/GearLever 2>/dev/null || true
        ok "Removed GameDev apps and configs."
        ;;

      2)
        echo "Skipping GameDev removal."
        ;;
esac

