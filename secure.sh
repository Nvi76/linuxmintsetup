#!/bin/bash
set -euo pipefail

# Ensure sudo access
sudo -v

# Chmod +x all files
chmod +x updater.sh removeconf.sh apps.sh firejail.sh ai_confs.sh

# Backup hosts & Copy file
sudo cp /etc/hosts "$HOME/linuxmintsetup/hosts.backup"
cp ~/linuxmintsetup/updater.sh ~/.updater.sh

# Installing hblock
curl -o /tmp/hblock 'https://raw.githubusercontent.com/hectorm/hblock/v3.5.1/hblock'
echo 'd010cb9e0f3c644e9df3bfb387f42f7dbbffbbd481fb50c32683bbe71f994451  /tmp/hblock' | shasum -c
sudo mv /tmp/hblock /usr/local/bin/hblock
sudo chown 0:0 /usr/local/bin/hblock
sudo chmod 755 /usr/local/bin/hblock
hblock

# Download Portmaster
curl -fL https://updates.safing.io/latest/linux_amd64/packages/Portmaster_2.1.7_amd64.deb \
-o portmaster.deb

# Install base packages & security apps
sudo apt update
sudo apt install -y nala git curl
sudo nala install -y build-essential fish figlet extrepo \
clamav clamav-base clamav-freshclam fail2ban ufw gufw apparmor-utils apparmor-profiles apparmor-profiles-extra rkhunter wget curl jq software-properties-common gawk
sudo nala install -y ./portmaster.deb || sudo apt -f install -y

# Rkhunter Fix to allow updates
echo "Fixing rkhunter configuration..."
sudo sed -i 's/^MIRRORS_MODE=1/MIRRORS_MODE=0/' /etc/rkhunter.conf
sudo sed -i 's/^UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/' /etc/rkhunter.conf
sudo sed -i 's/^WEB_CMD="\/bin\/false"/WEB_CMD=""/' /etc/rkhunter.conf

# Rkhunter Config
sudo rkhunter --propupd || true
sudo rkhunter --update || true
sudo rkhunter --config-check || true

# Firejail Configuration
source firejail.sh

# Fail2ban Configuration
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
filter = sshd[mode=aggressive]

[recidive]
enabled = true
logpath = /var/log/fail2ban.log
bantime = 604800
findtime = 86400
maxretry = 2
EOF"

    sudo systemctl reload fail2ban && \
    echo "Fail2Ban configuration applied." || \
    echo "Reload failed."
else
    echo "jail.local already exists. No changes made."
fi

# UFW Configuration
sudo ufw default deny incoming || exit 1
sudo ufw default allow outgoing || exit 1
sudo ufw enable || exit 1

# Enabling service
sudo systemctl enable --now portmaster || exit 1
sudo systemctl enable --now fail2ban || exit 1
sudo systemctl enable --now ufw || exit 1
sudo systemctl enable --now clamav-freshclam || exit 1
sudo systemctl enable --now apparmor || exit 1

# Git Setup
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

# Cleanup
rm -f portmaster.deb

# Clamav & Rkhunter
sudo systemctl stop clamav-freshclam || exit 1
sudo freshclam || exit 1
sudo rkhunter --update || exit 1
sudo systemctl start clamav-freshclam || exit 1

clear
echo "========================================"
echo "       Security Setup Complete.         "
echo "========================================"
