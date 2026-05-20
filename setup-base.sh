#!/usr/bin/env bash
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

# Ensure sudo access
sudo -v

# Chmod +x all files
chmod +x updater.sh removeconf.sh setup-desktop.sh ai_confs.sh

# Backup hosts & Copy file
sudo cp /etc/hosts "$HOME/linuxmintsetup/hosts.backup"
cp  ~/linuxmintsetup/updater.sh ~/.updater.sh  || exit 1

# ===============
#    Security
# ===============

# Install base packages & security apps
sudo apt update
sudo apt install -y nala git curl
sudo nala install -y build-essential fish figlet extrepo \
apparmor-utils apparmor-profiles apparmor-profiles-extra wget curl jq software-properties-common gawk

# Hblock
if yn "Do you want to install Hblock?" Y; then
    curl -o /tmp/hblock 'https://raw.githubusercontent.com/hectorm/hblock/v3.5.1/hblock'
    echo 'd010cb9e0f3c644e9df3bfb387f42f7dbbffbbd481fb50c32683bbe71f994451  /tmp/hblock' | shasum -c
    sudo mv /tmp/hblock /usr/local/bin/hblock
    sudo chown 0:0 /usr/local/bin/hblock
    sudo chmod 755 /usr/local/bin/hblock
    hblock
fi

# Download Portmaster
if yn "Do you want to install Portmaster?" Y; then

    info "Downloading Portmaster"
    curl -fL https://updates.safing.io/latest/linux_amd64/packages/Portmaster_2.1.7_amd64.deb \
    -o portmaster.deb

    sudo nala install -y ./portmaster.deb || sudo apt -f install -y
    sudo systemctl enable --now portmaster || exit 1
fi

# Rkhunter
if yn "Install & Configure Rkhunter?" Y; then

    sudo nala install -y rkhunter
    if command -v rkhunter &>/dev/null; then
        echo "Fixing rkhunter configuration..."
        sudo sed -i 's/^MIRRORS_MODE=1/MIRRORS_MODE=0/' /etc/rkhunter.conf
        sudo sed -i 's/^UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/' /etc/rkhunter.conf
        sudo sed -i 's/^WEB_CMD="\/bin\/false"/WEB_CMD=""/' /etc/rkhunter.conf

        sudo rkhunter --propupd || true
        sudo rkhunter --update || true
        sudo rkhunter --config-check || true
    fi
fi

# Firejail Configuration
if yn "Install & Configure Firejail?" Y; then
    firejail_install
fi

# Fail2ban
if yn "Install & Configure Fail2ban?" Y; then

    sudo nala install -y fail2ban

    if ! sudo test -f /etc/fail2ban/jail.local; then
        sudo bash -c "cat << 'EOF' > /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
backend = auto
mode = aggressive

[recidive]
enabled = true
logpath = /var/log/fail2ban.log
bantime = 604800
findtime = 86400
maxretry = 2
EOF"

        sudo systemctl enable --now fail2ban || exit 1
        sudo systemctl reload fail2ban && \
        ok "Fail2Ban configuration applied." || \
        err "Reload failed."
    else
        info "jail.local already exists. No changes made."
    fi
fi

# Clamav
if yn "Install & Configure ClamAV?" Y; then
    sudo nala install -y clamav-base clamav-freshclam
    sudo systemctl enable --now clamav-freshclam || exit 1
fi

# UFW
if yn "Install & Configure UFW?" Y; then
    sudo nala install -y ufw gufw
    sudo ufw default deny incoming || exit 1
    sudo ufw default allow outgoing || exit 1
    sudo ufw enable || exit 1
    sudo systemctl enable --now ufw || exit 1
fi

# ===============
#   Development
# ===============

# Git Setup
if yn "Configure Git?" Y; then
    echo "Setting up Git..."
    read -p "Enter your name: " git_name
    read -p "Enter your email: " git_email

    git config --global user.name "$git_name" || exit 1
    git config --global user.email "$git_email" || exit 1

    echo "Git configured with name: $git_name and email: $git_email"

    # Generate SSH key for GitHub
    if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
        mkdir -p "$HOME/.ssh"
        ssh-keygen -t ed25519 -C "$git_email" -N "" -f "$HOME/.ssh/id_ed25519"
        echo "SSH key generated. Add this to GitHub -> Settings -> SSH keys:"
        cat "$HOME/.ssh/id_ed25519.pub"
    else
        echo "SSH key already exists at ~/.ssh/id_ed25519.pub"
    fi
fi

# Homebrew
if yn "Do you want to install Homebrew? (y/n):" Y; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1

    # Load Homebrew for current session
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

fi

# Installing LazyVim
if yn "Do you want to install Neovim? & configure LazyVim?" Y; then

    # Homebrew apps
    brew install neovim || {
    err "Warning neovim installation failed. is homebrew installed?"
    exit 1
    }

    # Files & Folders
    mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
    mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true
    mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null || true
    mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null || true

    # Clone LazyVim starter
    info "Cloning LazyVim starter..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim

    # Remove git history
    rm -rf ~/.config/nvim/.git

    # Enable system clipboard
    mkdir -p ~/.config/nvim/lua/config
    grep -q "clipboard.*unnamedplus" ~/.config/nvim/lua/config/options.lua 2>/dev/null || echo 'vim.opt.clipboard = "unnamedplus"' >> ~/.config/nvim/lua/config/options.lua

    # Neovim Config
    nvim
fi

# Cleanup
rm -f portmaster.deb || true

# Enabling service
if command -v apparmor_status &>/dev/null; then
    sudo systemctl enable --now apparmor || exit 1
fi

# Clamav & Rkhunter
if command -v clamscan &>/dev/null; then
    sudo systemctl stop clamav-freshclam || exit 1
    sudo freshclam || exit 1
    sudo systemctl start clamav-freshclam || exit 1
fi

if command -v rkhunter &>/dev/null; then
    sudo rkhunter --update || exit 1
fi

# ================
#   Shell Config
# ================

# Shell Configuration
configure_shells() {
    clear
    header "Shell Configuration"
    echo "Setup & Configure Shells? "
    echo "1) Bash (ble.sh, bash-completion, atuin)"
    echo "2) Zsh (Oh My Zsh, autosuggestions, syntax-highlighting)"
    echo "3) Fish (Config, aliases)"
    echo "4) All of the above"
    echo "5) Skip"

    case $(pick "Choice [1-5]:" 1 5) in
        '1') configure_bash ;;
        '2') configure_zsh ;;
        '3') configure_fish ;;
        '4') configure_bash; configure_zsh; configure_fish ;;
        '5') info "Skipping Shell Configuration." ;;
        *) err "Invalid choice."; exit 1 ;;
    esac

    # Set default shell
    clear
    header "Set Default Shell"
    echo "Change Default Shell"
    echo "1) Keep Bash"
    echo "2) Fish"
    echo "3) Zsh"
    echo "4) Skip"
    case $(pick "Choice [1-4]:" 1 4) in
        '1') sudo chsh -s /bin/bash ;;
        '2') sudo chsh -s "$(which fish)" "$USER" ;;
        '3') sudo chsh -s "$(which zsh)" "$USER" ;;
        '4') info "Skipping..." ;;
        *) err "Invalid choice." ;;
    esac
}

configure_shells

clear
echo "========================================"
echo "       Security Setup Complete.         "
echo "========================================"
