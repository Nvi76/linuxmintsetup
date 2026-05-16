#!/usr/bin/env bash

# Functions
yn_default() {
    local prompt="$1"
    local confirm_msg="$2"
    local skip_msg="$3"
    clear
    echo "${prompt}"
    while true; do
        read -t 5 -p "Answer [y/n]: " reply
        if [ -z "$reply" ]; then
            reply="Y"
        fi
        case $reply in
            Y|y)
                echo "${confirm_msg}"
                return 0
                ;;
            N|n)
                echo "${skip_msg}"
                return 1
                ;;
            *)
                echo "Please enter 'y' or 'n'."
                ;;
        esac
    done
}

yn_second() {
    local prompt="$1"
    local confirm_msg="$2"
    local skip_msg="$3"
    clear
    echo "${prompt}"
    while true; do
        read -t 5 -rp "Answer [y/n]: " reply
        reply=${reply:-N}
        case "$reply" in
            [Yy])
                echo "${confirm_msg}"
                return 0
                ;;
            [Nn])
                echo "${skip_msg}"
                return 1
                ;;
            *)
                echo "Please answer y or n."
                ;;
        esac
    done
}

edu_apps() {
    echo "Select packages to install:"
    echo "1) Preschool (TK)"
    echo "2) Primary (SD)"
    echo "3) Secondary (SMP-SMA)"
    echo "4) Tertiary (Collage Level)"
    echo "5) All"
    echo -n "Enter choice (1-5): "
    read choice

    case $choice in
        1) sudo nala install -y ubuntu-edu-preschool ;;
        2) sudo nala install -y ubuntu-edu-primary ;;
        3) sudo nala install -y ubuntu-edu-secondary ;;
        4) sudo nala install -y ubuntu-edu-tertiary ;;
        5) sudo nala install -y ubuntu-edu-preschool ubuntu-edu-primary ubuntu-edu-secondary ubuntu-edu-tertiary ;;
        *) echo "Invalid option" ;;
    esac
}


# Checking
clear
echo "Did you installed the nvidia drivers already or are you using other gpus not needing any drivers? (y/n):"

while true; do
    read -p "Answer [y/n]: " reply

    case $reply in
        Y|y)
            echo "Continuing..."
            break
            ;;
        N|n)
            echo "Go and install the nvidia driver first first."
            break
            ;;
        *)
            echo "Please enter 'y' or 'n'."
            ;;
    esac
done

# Update system
sudo nala full-upgrade -y || exit 1

# Install Deb Apps
sudo nala install -y vulkan-tools build-essential python3-tk tmux unzip xclip || exit 1

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1

# Install Nixpkgmngr
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

# Configuring nix
mkdir -p ~/.config/nix
grep -q 'experimental-features = nix-command' ~/.config/nix/nix.conf 2>/dev/null || echo 'experimental-features = nix-command' >> ~/.config/nix/nix.conf

# Load Homebrew for current session
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Homebrew apps
if command -v brew &>/dev/null; then
    brew install neovim distrobox podman fzf ranger btop thefuck trash-cli fastfetch
fi

clear
echo "======================="
echo "     20% Complete      "
echo "======================="
timeout 1s sleep 1

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
if yn_default "Do you want to install GameDev Apps? (y/n):" "Installing Godot & libresprite..." "Skipping GameDev Apps installation."; then
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

clear
echo "======================="
echo "     50% Complete      "
echo "======================="
timeout 1s sleep 1

# Installing LazyVim
clear
echo "============================"
echo "     Installing LazyVim     "
echo "============================"

mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null || true
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null || true

# Clone LazyVim starter
echo "Cloning LazyVim starter..."
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Remove git history
rm -rf ~/.config/nvim/.git

# Enable system clipboard
mkdir -p ~/.config/nvim/lua/config
grep -q "clipboard.*unnamedplus" ~/.config/nvim/lua/config/options.lua 2>/dev/null || echo 'vim.opt.clipboard = "unnamedplus"' >> ~/.config/nvim/lua/config/options.lua

# Neovim Config
nvim

clear
echo "======================="
echo "     70% Complete      "
echo "======================="
timeout 1s sleep 1

# Install Flatpak apps
flatpak install flathub \
  com.rtosta.zapzap \
  org.telegram.desktop \
  org.gimp.GIMP \
  com.github.tchx84.Flatseal \
  net.agalwood.Motrix \
  org.localsend.localsend_app \
  com.logseq.Logseq \
  org.kde.kate \
  org.kde.kdenlive \
  --noninteractive

clear
echo "======================="
echo "     80% Complete      "
echo "======================="
timeout 1s sleep 1

# Shell Configuration
configure_shells() {
    clear
    echo "================================================="
    echo "           Setup & Configure Shells"
    echo "================================================="
    echo "Which shell(s) would you like to configure?"
    echo "1) Bash (ble.sh, bash-completion, atuin, homebrew, nix)"
    echo "2) Zsh (Oh My Zsh, autosuggestions, syntax-highlighting)"
    echo "3) Fish (Config, aliases)"
    echo "4) All of the above"
    echo "5) Skip"

    read -p $'\e[32mEnter choice [1-5]: \e[0m' shell_choice

    configure_bash() {
        clear
        echo "================================================="
        echo "               Configuring Bash"
        echo "================================================="

        # bash-completion
        echo "Installing bash-completion..."
        sudo nala install -y bash-completion

        # Install Atuin
        if ! command -v atuin &>/dev/null; then
            curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || exit 1
        fi

        # ble.sh
        clear
        echo "Do you want to install ble.sh? (y/n):"
        while true; do
            read -t 5 -rp "Answer [y/n]: " reply
            reply=${reply:-Y}
            case $reply in
                [Yy])
                    echo "How would you like to install ble.sh?"
                    echo "1) Git"
                    echo "2) Nix"
                    read -p $'\e[32mEnter choice [1-2]: \e[0m' ble_choice
                    case $ble_choice in
                        '1')
                            git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
                            make -C /tmp/ble.sh install PREFIX="$HOME/.local"
                                grep -q "blesh/ble.sh" "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" << 'EOF'

# ble.sh
[ -f "$HOME/.local/share/blesh/ble.sh" ] && source "$HOME/.local/share/blesh/ble.sh"
EOF
                            ;;
                        '2')
                            nix profile install nixpkgs#ble-sh
                                grep -q "blesh/ble.sh" "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" << 'EOF'

# ble.sh
[ -f "$HOME/.local/share/blesh/ble.sh" ] && source "$HOME/.local/share/blesh/ble.sh"
EOF

cat > ~/.blerc << 'EOF'
# Performance-optimized ble.sh settings
bleopt complete_auto_delay=200
bleopt highlight_syntax=
bleopt complete_auto_history=

# History limits to reduce overhead
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

# Visual bell
bleopt edit_bell=vbell
EOF
                            ;;
                        *)
                            echo "Invalid choice. Skipping ble.sh."
                            ;;
                    esac
                    break
                    ;;
                [Nn])
                    echo "Skipping ble.sh installation."
                    break
                    ;;
                *)
                    echo "Please answer y or n."
                    ;;
            esac
        done

grep -q "=== apps.sh managed block" "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" << 'BASHEOF'
# === apps.sh managed block - do not edit manually ===
eval "$(atuin init bash)"

[ -f "$HOME/.local/share/blesh/ble.sh" ] && source "$HOME/.local/share/blesh/ble.sh"

alias lsa="ls -a"
alias update="~/.updater.sh"
alias scan="clamscan -r"
alias trm="trash-put"
alias trestore="trash-restore"
alias tbin="trash-empty"
alias listt="trash-list"
alias copy="wl-copy <"
alias paste="wl-paste >"
alias rkscan="sudo rkhunter --check --sk"
alias kate="flatpak run org.kde.kate"

# Extra functions
gitpush_installscript() {
    cd ~/Projects/Scripts/linuxmintsetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/fedorasetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/voidsetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/cachysetup && git add . && git commit -m "New changes" && git push -u origin main
}

# Copy Ai models to folder
ollama_model() {
  local model_name=$1

  if [ -z "$model_name" ]; then
    echo "Usage: copy_ollama_model <model-name>"
    return 1
  fi

  ollama export "$model_name" "./${model_name//:/_}.bin"
  echo "Model '$model_name' exported to $(pwd)/${model_name//:/_}.bin"
}

ollama_models_all() {
  local export_dir="./ollama-backup"
  mkdir -p "$export_dir"

  ollama list --format json | jq -r '.[].name' | while read model; do
    echo "Exporting $model..."
    ollama export "$model" "$export_dir/${model//:/_}.bin"
  done

  echo "All models exported to $export_dir"
}

# Homebrew
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Thefuck
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

# OpenCode
export PATH="$PATH:$HOME/.opencode/bin"
if command -v opencode &>/dev/null; then
    source <(opencode completion bash 2>/dev/null) 2>/dev/null || true
fi

# === end of apps.sh block ===
BASHEOF
        echo "Bash configured at ~/.bashrc"
        timeout 1s sleep 1
    }

    configure_zsh() {
        clear
        echo "================================================="
        echo "               Configuring Zsh"
        echo "================================================="

        # Install zsh
        sudo nala install -y zsh

        # Install Oh My Zsh
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi

        # Install zsh-autosuggestions
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
        fi

        # Install zsh-syntax-highlighting
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
        fi

        # Configure .zshrc plugins
        if grep -q "^plugins=" "$HOME/.zshrc" 2>/dev/null; then
            sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
        fi
        
        # Install Atuin
        if ! command -v atuin &>/dev/null; then
            curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || exit 1
        fi

            grep -q "=== apps.sh managed block" "$HOME/.zshrc" 2>/dev/null || cat >> "$HOME/.zshrc" << 'ZSHEOF'
# === apps.sh managed block - do not edit manually ===
eval "$(atuin init zsh)"

# Aliases
alias lsa="ls -a"
alias update="~/.updater.sh"
alias scan="clamscan -r"
alias trm="trash-put"
alias trestore="trash-restore"
alias tbin="trash-empty"
alias listt="trash-list"
alias copy="wl-copy <"
alias paste="wl-paste >"
alias rkscan="sudo rkhunter --check --sk"
alias kate="flatpak run org.kde.kate"

# Extra functions
gitpush_installscript() {
    cd ~/Projects/Scripts/linuxmintsetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/fedorasetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/voidsetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/cachysetup && git add . && git commit -m "New changes" && git push -u origin main
}

# Copy Ai models to folder
ollama_model() {
  local model_name=$1

  if [ -z "$model_name" ]; then
    echo "Usage: copy_ollama_model <model-name>"
    return 1
  fi

  ollama export "$model_name" "./${model_name//:/_}.bin"
  echo "Model '$model_name' exported to $(pwd)/${model_name//:/_}.bin"
}

ollama_models_all() {
  local export_dir="./ollama-backup"
  mkdir -p "$export_dir"

  ollama list --format json | jq -r '.[].name' | while read model; do
    echo "Exporting $model..."
    ollama export "$model" "$export_dir/${model//:/_}.bin"
  done

  echo "All models exported to $export_dir"
}

# Homebrew
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Thefuck
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

# Opencode
export PATH="$PATH:$HOME/.opencode/bin"
if command -v opencode &>/dev/null; then
    source <(opencode completion zsh 2>/dev/null) 2>/dev/null || true
fi

# === end of apps.sh block ===
ZSHEOF
        echo "Zsh configured at ~/.zshrc"
        timeout 1s sleep 1
    }

    configure_fish() {
        clear
        echo "================================================="
        echo "                Configuring Fish"
        echo "================================================="

        # Install fish if not present
        if command -v fish &>/dev/null; then
            sudo nala install -y fish
        fi

        # Install Atuin
        if ! command -v atuin &>/dev/null; then
            curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || exit 1
        fi

        # Configure fish
        FISH_CONFIG_DIR="$HOME/.config/fish"
        FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"
        mkdir -p "$FISH_CONFIG_DIR"

            cat > "$FISH_CONFIG_FILE" << 'FISHEOF'
if status is-interactive
    set -gx ATUIN_NOBIND true
    atuin init fish | source

    bind \e\[A _atuin_bind_up
    bind \cr _atuin_search

    if bind -M insert >/dev/null 2>&1
        bind -M insert \e\[A _atuin_bind_up
        bind -M insert \cr _atuin_search
    end

    bind \e\[3\;5~ kill-word
    bind \cH backward-kill-word
end

# Aliases
alias lsa "ls -a "
alias update "~/.updater.sh "
alias scan "clamscan -r "
alias trm "trash-put "
alias trestore "trash-restore "
alias tbin "trash-empty "
alias listt "trash-list "
alias copy "wl-copy < "
alias paste "wl-paste > "
alias rkscan "sudo rkhunter --check --sk "
alias kate "flatpak run org.kde.kate "

# Extra functions
function gitpush_installscript
    cd ~/Projects/Scripts/linuxmintsetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/fedorasetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/voidsetup && git add . && git commit -m "New changes" && git push -u origin main
    cd ~/Projects/Scripts/cachysetup && git add . && git commit -m "New changes" && git push -u origin main
end

# Copy Ai models to folder
function ollama_model
    local model_name=$1

    if [ -z "$model_name" ]; then
        echo "Usage: copy_ollama_model <model-name>"
        return 1
    fi

    ollama export "$model_name" "./${model_name//:/_}.bin"
    echo "Model '$model_name' exported to $(pwd)/${model_name//:/_}.bin"
end

function ollama_models_all
    local export_dir="./ollama-backup"
    mkdir -p "$export_dir"

    ollama list --format json | jq -r '.[].name' | while read model; do
        echo "Exporting $model..."
        ollama export "$model" "$export_dir/${model//:/_}.bin"
    done

    echo "All models exported to $export_dir"
end

# Homebrew
if test -f /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

# Thefuck
if command -v thefuck >/dev/null
    thefuck --alias | source
end
FISHEOF
        echo "Fish configured at $FISH_CONFIG_FILE"
        timeout 1s sleep 1
    }

    case $shell_choice in
        '1')
            configure_bash
            ;;

        '2')
            configure_zsh
            ;;

        '3')
            configure_fish
            ;;

        '4')
            configure_bash
            configure_zsh
            configure_fish
            ;;

        '5')
            echo "=================================================="
            echo "          Skipping Shell Configuration.          "
            echo "=================================================="
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

configure_shells

# Set default shell
clear
echo "======================================="
echo "           Set Default Shell"
echo "======================================="
echo "1) Keep Bash"
echo "2) Fish"
echo "3) Zsh"
echo "4) Skip"

# Use ANSI escape codes for colored prompt
read -p $'\e[32mEnter choice [1-4]: \e[0m' choice

case $choice in
    '1')
        # Bash
        echo "Keeping Bash.."
        sudo chsh -s /bin/bash
        timeout 1s sleep 1
        ;;
    
    '2')
        # Fish
        sudo chsh -s "$(which fish)" "$USER"
        timeout 1s sleep 1
        ;;
    '3') 
        # Zsh
        sudo chsh -s "$(which zsh)" "$USER"
        timeout 1s sleep 1 
        ;;

    '4')
        clear
        echo "================================"
        echo "          Skipping.....         "
        echo "================================"
        ;;
    *)
        echo "Invalid choice."
        ;;
esac

# Final Checks
sudo nala full-upgrade || exit 1

echo "=================================================="
echo "     Setup Complete :> , Please Reboot Your PC    "
echo "=================================================="
