#!/usr/bin/env bash
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

# Checking
clear
echo "Did you install the nvidia drivers already or are you using other gpus not needing any drivers? (y/n):"

while true; do
    read -p "Answer [y/n]: " reply

    case $reply in
        Y|y)
            echo "Continuing..."
            break
            ;;
        N|n)
            echo "Go and install the nvidia driver first."
            break
            ;;
        *)
            echo "Please enter 'y' or 'n'."
            ;;
    esac
done

# Update system
sudo nala full-upgrade -y || exit 1

# ===============
#      Apps
# ===============

# Install Deb Apps
if yn_default "Do you want to install .deb Apps?" "Installing .deb Apps..." "Skipping Installation"; then
    sudo nala install -y vulkan-tools build-essential python3-tk tmux unzip xclip || exit 1
fi

# Nix
if yn_default "Do you want to install NixPkg Manager? (y/n):" "Installing NixPkg Manager..." "Skipping installation."; then

    # Install Nixpkgmngr
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

    # Configuring nix
    mkdir -p ~/.config/nix
    grep -q 'experimental-features = nix-command' ~/.config/nix/nix.conf 2>/dev/null || echo 'experimental-features = nix-command' >> ~/.config/nix/nix.conf

fi

# Homebrew
if yn_default "Do you want to install Homebrew & Homebrew Apps? (y/n):" "Installing Homebrew..." "Skipping installation."; then

    # Load Homebrew for current session
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    # Homebrew apps
    if command -v brew &>/dev/null; then
        brew install distrobox podman fzf ranger btop thefuck trash-cli fastfetch
    fi

fi

# Install Additional Browsers
clear
echo "=========================================="
echo "           Additional Browsers"
echo "=========================================="
timeout 2s sleep 2

# Helium Browser
if yn_default "Do you want to install Helium? (y/n):" "Installing browser..." "Skipping browser installation."; then

    # Add Helium's signing public key
    curl -fsSL https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc | sudo gpg --dearmor -o /usr/share/keyrings/helium.gpg

    # Add Helium's repo
    echo "deb [signed-by=/usr/share/keyrings/helium.gpg] https://pkg.helium.computer/deb stable main" | sudo tee /etc/apt/sources.list.d/helium.list

    # Install Helium browser
    sudo nala update && sudo nala install -y helium-bin
fi

# Brave Browser
if yn_default "Do you want to install Brave Browser? (y/n):" "Installing browser..." "Skipping browser installation."; then
    # Import Brave Browser's Repo
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

    sudo nala update
    sudo nala install -y brave-browser
fi

# Librewolf
if yn_default "Do you want to install Librewolf? (y/n):" "Installing browser..." "Skipping browser installation."; then
    # Enable Librewolf's repo
    sudo extrepo update librewolf || exit 1

    sudo nala update
    sudo nala install -y librewolf
fi

# Mullvad Browser
if yn_default "Do you want to install Mullvad Browser? (y/n):" "Installing browser..." "Skipping browser installation."; then
    flatpak install flathub net.mullvad.MullvadBrowser --noninteractive
fi

# Floorp Browser
if yn_default "Do you want to install Floorp? (y/n):" "Installing browser..." "Skipping browser installation."; then
    flatpak install flathub one.ablaze.floorp --noninteractive
fi

# Zen Browser
if yn_default "Do you want to install Zen Browser? (y/n):" "Installing browser..." "Skipping browser installation."; then
    flatpak install flathub app.zen_browser.zen --noninteractive
fi

clear
echo "============================================="
echo "           Additional Tools & Games          "
echo "============================================="
timeout 2s sleep 2

# Install Additional
if yn_second "Do you want to install Additional tools? (Might not be needed for desktop usage) (y/n)" "Installing tools..." "Skipping installation."; then
    wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
    sudo dpkg -i protonvpn-stable-release_1.0.8_all.deb

    sudo add-apt-repository -y ppa:micahflee/ppa
    sudo nala install -y proton-vpn-cli torbrowser-launcher
    sudo systemctl start proton-vpn-daemon.service

    sudo protonvpn init
    protonvpn connect --fastest > /dev/null
fi

# Additionals2
clear
URL="http://127.0.0.1:7657/"
BROWSERS=("firefox" "chromium-browser")

install_browser() {
    local browser=$1
    echo "Installing $browser..."
    sudo nala update
    sudo nala install -y "$browser"
}

if yn_second "Do you want to install Additional tool? (2) (y/n)" "Installing tools..." "Skipping installation."; then
    sudo add-apt-repository -y ppa:i2p-maintainers/i2p

    sudo nala update
    sudo nala install -y i2pd curl

    sudo systemctl start i2pd > /dev/null 2>&1

    until curl -s http://127.0.0.1:7657 > /dev/null; do
        sleep 2
    done

    found=false

    for browser in "${BROWSERS[@]}"; do
        if command -v "$browser" &>/dev/null; then
            echo "Launching $browser..."
            "$browser" "$URL" &
            found=true
        fi
    done

    if ! $found; then
        echo "No supported browser found."
        echo "1) firefox"
        echo "2) chromium-browser"

        read -rp "Choice [1-2]: " choice

        case "$choice" in
            1) install_browser firefox ;;
            2) install_browser chromium-browser ;;
            *) echo "Invalid option" ;;
        esac
    fi
fi

# Game Dev
if yn_default "Do you want to install GameDev Apps? (y/n):" "Installing GameDev Apps..." "Skipping GameDev Apps installation."; then
    gamedev_dir=~/linuxmintsetup
    mkdir -p "$gamedev_dir"

    echo "Installing Godot..."
    curl -fL \
        https://github.com/godotengine/godot/releases/download/4.6.2-stable/Godot_v4.6.2-stable_linux.x86_64.zip \
        -o "$gamedev_dir/Godot_v4.6.2-stable_linux.x86_64.zip" || exit 1

    unzip -o "$gamedev_dir/Godot_v4.6.2-stable_linux.x86_64.zip" -d "$gamedev_dir"

    echo "Installing LDtk..."
    curl -fL \
        https://github.com/deepnight/ldtk/releases/download/v1.5.3/LDtk-1.5.3-linux.zip \
        -o "$gamedev_dir/LDtk.zip" || exit 1

    unzip -o "$gamedev_dir/LDtk.zip" -d "$gamedev_dir"
    flatpak install flathub it.mijorus.gearlever --noninteractive
    flatpak run it.mijorus.gearlever "$gamedev_dir"/*.AppImage

    echo "Installing Libresprite..."
    curl -fL \
        https://github.com/LibreSprite/LibreSprite/releases/download/v24.08.0/libresprite-development-linux-x86_64.zip \
        -o "$gamedev_dir/libresprite.zip" || exit 1

    unzip -o "$gamedev_dir/libresprite.zip" -d "$gamedev_dir"
    flatpak run it.mijorus.gearlever "$gamedev_dir"/LibreSprite*.AppImage

    trash-put "$gamedev_dir/Godot_v4.6.2-stable_linux.x86_64.zip"
    trash-put "$gamedev_dir/LDtk.zip"
    trash-put "$gamedev_dir/libresprite.zip"
fi

# Games
if yn_default "Do you want to install Games aswell? (y/n):" "Installing Games..." "Skipping installation of games."; then
    flatpak install flathub org.luanti.luanti info.beyondallreason.bar org.openttd.OpenTTD net.openra.OpenRA net.wz2100.wz2100 --noninteractive
fi

# Code
if yn_default "Do you want to install VSCode (y/n):" "Installing VSCode..." "Skipping VSCode installation."; then
    # Download VS Code
    curl -fL \
        https://vscode.download.prss.microsoft.com/dbazure/download/stable/bdd88df003631aaa0bcbe057cb0a940b80a476fa/code_1.109.0-1770171879_amd64.deb \
        -o vscode.deb || exit 1

    sudo nala install ./vscode.deb -y || sudo apt -f install -y

    # Cleanup
    trash-put vscode.deb
fi

# Codium
if yn_default "Do you want to install VSCodium (y/n):" "Installing VSCodium..." "Skipping VSCodium installation."; then

    # Import VSCodium keyring
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        | gpg --dearmor \
        | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg || exit 1

    echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
        | sudo tee /etc/apt/sources.list.d/vscodium.sources

    sudo nala update
    sudo nala install -y codium
fi

# Logseq
if yn_default "Do you want to install Logseq (y/n):" "Installing Logseq..." "Skipping Logseq installation."; then
    flatpak install flathub com.logseq.Logseq --noninteractive
fi

# Educational Apps
if yn_default "Do you want to Educational Apps (Edubuntu)? (y/n):" "Installing Educational Apps..." "Skipping installation of Educational Apps..."; then
    edu_apps
fi

# VirtManager (GnomeBoxes)
if yn_default "Do you want to install VirtManager (GnomeBoxes) (y/n):" "Installing VirtManager..." "Skipping VirtManager installation."; then
    flatpak install flathub --noninteractive org.gnome.Boxes
fi

# AI Tools
clear
echo "=============================="
echo "           AI Tools"
echo "=============================="
timeout 2s sleep 2

# Ollama
if yn_default "Do you want to install Ollama? (y/n):" "Installing Ollama..." "Skipping Ollama installation."; then
    echo "Installing Dependencies"
    sudo nala install -y nvidia-cuda-toolkit            

    curl -fsSL https://ollama.com/install.sh | sh

    echo "Enabling system service"
    sudo systemctl enable ollama
fi

# OpenCode
if yn_default "Do you want to install OpenCode? (y/n):" "Installing OpenCode..." "Skipping OpenCode installation."; then
    curl -fsSL https://opencode.ai/install | bash
fi

# Oterm
if yn_default "Do you want to install Oterm? (y/n):" "Installing Oterm..." "Skipping Oterm installation."; then
    brew install oterm

    mkdir -p "$(oterm --data-dir 2>/dev/null || echo ~/.local/share/oterm)" && \
    config="$(oterm --data-dir 2>/dev/null || echo ~/.local/share/oterm)/config.json" && \
    if [ -f "$config" ]; then
    tmp=$(mktemp) && jq '. + {"splash-screen": false}' "$config" > "$tmp" && mv "$tmp" "$config"
    else
    echo '{"splash-screen": false}' > "$config"
    fi
fi

# Alpaca
if yn_default "Do you want to install Alpaca? (y/n):" "Installing Alpaca..." "Skipping Alpaca installation."; then
    flatpak install flathub com.jeffser.Alpaca --noninteractive
fi

# Run AI configuration
has_ollama=$(command -v ollama)
has_opencode=$(command -v opencode)

if [ -n "$has_ollama" ] || [ -n "$has_opencode" ]; then
    clear
    echo "Configuring AI tools..."
    ~/linuxmintsetup/ai_confs.sh
fi

# Install Flatpak apps
if yn_default "Do you want to install flatpak apps?" "Installing flatpak apps..." "Skipping installation."; then
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
echo "================================================"
echo "           Power / Battery Utilities"
echo "================================================"
echo "Which power management tool would you like to install?"
echo "1) auto-cpufreq"
echo "2) TLP"
echo "3) Skip Installation"

read -p "Enter choice [1-3]: " choice

case $choice in
    '1')
        echo "Installing auto-cpufreq..."
        sudo nala update || exit 1
        git clone https://github.com/AdnanHodzic/auto-cpufreq.git || exit 1
        cd auto-cpufreq || exit 1
        sudo ./auto-cpufreq-installer || exit 1
        cd .. && rm -rf auto-cpufreq

        echo "================================================"
        echo "       Power Management Setup Complete.         "
        echo "================================================"
        ;;
    '2')
        echo "Installing TLP..."
        sudo nala update || exit 1
        sudo nala install -y tlp tlp-rdw || exit 1
        sudo systemctl enable --now tlp || exit 1

        echo "================================================"
        echo "       Power Management Setup Complete.         "
        echo "================================================"
        ;;
    '3')
        echo "Exiting."
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

# Final Checks
sudo nala full-upgrade || exit 1

echo "=================================================="
echo "     Setup Complete :> , Please Reboot Your PC    "
echo "=================================================="
