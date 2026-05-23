#!/usr/bin/env bash
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

# ===============
#     System
# ===============

# NVIDIA check
clear
header "Nvidia / GPU Drivers"
info "Did you install the Nvidia drivers already?"

if ! yn ""; then
  info "Go and install it first in the driver manager"
  sleep 1
  exit 0
fi

# Update system
sudo nala full-upgrade -y
ok "System Updated" || exit 1

# ===============
#      Apps
# ===============

clear
header "Additional Browsers"

# Helium Browser
if yn "Do you want to install Helium?" Y; then
  # Add Helium's signing public key
  curl -fsSL https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc | sudo gpg --dearmor -o /usr/share/keyrings/helium.gpg

  # Add Helium's repo
  echo "deb [signed-by=/usr/share/keyrings/helium.gpg] https://pkg.helium.computer/deb stable main" | sudo tee /etc/apt/sources.list.d/helium.list

  # Install Helium browser
  sudo nala update && sudo nala install -y helium-bin
fi

# Brave Browser
if yn "Do you want to install Brave Browser?" Y; then
  info "Use Official Repo or Use Flatpak?"
  case $(pick "Choice [1-2]" 1 2) in
  '1')

    # Import Brave Browser's Repo
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

    sudo nala update
    sudo nala install -y brave-browser
    ;;

  '2')
    flatpak install flathub com.brave.Browser --noninteractive
    ;;
  esac
fi

# Librewolf
if yn "Do you want to install Librewolf?" Y; then
  # Enable Librewolf's repo
  sudo extrepo enable librewolf || exit 1

  sudo nala update
  sudo nala install -y librewolf
fi

# Mullvad Browser
if yn "Do you want to install Mullvad Browser?" Y; then
  flatpak install flathub net.mullvad.MullvadBrowser --noninteractive
fi

# Floorp Browser
if yn "Do you want to install Floorp?" Y; then
  flatpak install flathub one.ablaze.floorp --noninteractive
fi

# Zen Browser
if yn "Do you want to install Zen Browser?" Y; then
  flatpak install flathub app.zen_browser.zen --noninteractive
fi

clear
header "Additional Tools and Games"

# Office
if yn "Install Office Apps? (Libreoffice & Onlyoffice?)" Y; then
  if yn "Install Libreoffice?" Y; then sudo nala install -y libreoffice; fi
  if yn "Install OnlyOffice?" Y; then flatpak install flathub org.onlyoffice.desktopeditors --noninteractive; fi
fi

# Game Dev
if yn "Do you want to install GameDev Apps?" Y; then
  mkdir -p "$HOME/Projects/Programs"

  info "Installing Godot..."
  curl -fL \
    https://github.com/godotengine/godot/releases/download/4.6.2-stable/Godot_v4.6.2-stable_linux.x86_64.zip \
    -o "$HOME/Projects/Programs/Godot_v4.6.2-stable_linux.x86_64.zip" || exit 1

  unzip -o "$HOME/Projects/Programs/Godot_v4.6.2-stable_linux.x86_64.zip" -d "$HOME/Projects/Programs"

  curl -fL https://godotengine.org/assets/press/icon_color.svg -o "$HOME/Projects/Programs/godot_icon_color.svg" -d "$HOME/Projects/Programs"

  info "Install LDtk Manually"

  # LibreSprite
  info "Downloading LibreSprite..."
  flatpak install flathub com.github.libresprite.LibreSprite --noninteractive

  trash-put "$HOME/Applications/Godot_v4.6.2-stable_linux.x86_64.zip"
fi

# Games
if yn "Do you want to install Games aswell?" Y; then
  flatpak install flathub org.luanti.luanti info.beyondallreason.bar org.openttd.OpenTTD net.openra.OpenRA net.wz2100.wz2100 --noninteractive
fi

# Code
if yn "Do you want to install VSCode" Y; then
  # Download VS Code
  info "Downloading VSCode"
  curl -fL \
    https://vscode.download.prss.microsoft.com/dbazure/download/stable/bdd88df003631aaa0bcbe057cb0a940b80a476fa/code_1.109.0-1770171879_amd64.deb \
    -o vscode.deb || exit 1

  sudo nala install ./vscode.deb -y || sudo apt -f install -y

  # Cleanup
  trash-put vscode.deb
fi

# Codium
if yn "Do you want to install VSCodium" Y; then
  # Import VSCodium keyring
  wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg |
    gpg --dearmor |
    sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg || exit 1

  echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' |
    sudo tee /etc/apt/sources.list.d/vscodium.sources

  sudo nala update
  sudo nala install -y codium
fi

# Logseq
if yn "Do you want to install Logseq" Y; then
  flatpak install flathub com.logseq.Logseq --noninteractive
fi

# Educational Apps
if yn "Do you want to Educational Apps (Edubuntu)?" Y; then
  edu_apps
fi

# VirtManager (GnomeBoxes)
if yn "Do you want to install VirtManager (GnomeBoxes)" Y; then
  flatpak install flathub org.gnome.Boxes --noninteractive
fi

# AI Tools
clear
header "AI Tools"

# Ollama
if yn "Do you want to install Ollama?" Y; then
  info "Installing Dependencies..."
  sudo nala install -y nvidia-cuda-toolkit

  curl -fsSL https://ollama.com/install.sh | sh

  info "Enabling system service..."
  sudo systemctl enable ollama
fi

# OpenCode
if yn "Do you want to install OpenCode?" Y; then
  info "Installing OpenCode..."
  curl -fsSL https://opencode.ai/install | bash
fi

# Oterm
if yn "Do you want to install Oterm?" Y; then
  brew install oterm

  mkdir -p "$(oterm --data-dir 2>/dev/null || echo ~/.local/share/oterm)" &&
    config="$(oterm --data-dir 2>/dev/null || echo ~/.local/share/oterm)/config.json" &&
    if [ -f "$config" ]; then
      tmp=$(mktemp) && jq '. + {"splash-screen": false}' "$config" >"$tmp" && mv "$tmp" "$config"
    else
      echo '{"splash-screen": false}' >"$config"
    fi
fi

# Alpaca
if yn "Do you want to install Alpaca?" Y; then
  flatpak install flathub com.jeffser.Alpaca --noninteractive
fi

# Run AI configuration
has_ollama=$(command -v ollama)
has_opencode=$(command -v opencode)

if [ -n "$has_ollama" ] || [ -n "$has_opencode" ]; then
  clear
  echo "Configuring AI tools..."
  "$SCRIPT_DIR"/ai_confs.sh
fi

# Install Flatpak apps

clear
header "Flatpaks"
if yn "Do you want to install flatpak apps?" Y; then
  flatpak install flathub \
    com.rtosta.zapzap \
    org.telegram.desktop \
    org.gimp.GIMP \
    com.github.tchx84.Flatseal \
    net.agalwood.Motrix \
    org.localsend.localsend_app \
    org.kde.kate \
    org.kde.kdenlive \
    --noninteractive
fi

# Power Management
header "Power Management"
echo "Which power management tool would you like to install?"
echo "1) auto-cpufreq"
echo "2) TLP"
echo "3) Skip Installation"

case $(pick "Choice [1-3]:" 1 3) in
1)
  info "Installing auto-cpufreq..."
  sudo nala update || exit 1
  git clone https://github.com/AdnanHodzic/auto-cpufreq.git || exit 1
  cd auto-cpufreq || exit 1
  sudo ./auto-cpufreq-installer || exit 1
  cd .. && rm -rf auto-cpufreq

  ok "Power Management Setup Complete."
  ;;
2)
  info "Installing TLP..."
  sudo nala update || exit 1
  sudo nala install -y tlp tlp-rdw || exit 1
  sudo systemctl enable --now tlp || exit 1

  ok "Power Management Setup Complete."
  ;;
3)
  info "Exiting."
  ;;
*)
  err "Invalid option."
  exit 1
  ;;
esac

# Final Checks
sudo nala full-upgrade
ok "Final System Update Complete" || exit 1

ok "Setup Complete. Please Reboot Your PC"
