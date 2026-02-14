#!/bin/bash
set -euo pipefail

# Ensure sudo access
sudo -v

# Chmod +x all files
chmod +x updater.fish && chmod +x cliapps.fish && chmod +x apps.fish && autocpufreq.fish

# Backup directory
mkdir -p "$HOME/PopOS-setup"

# Backup hosts
sudo cp /etc/hosts "$HOME/PopOS-setup/hosts.backup"

# Download Portmaster
curl -fL https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.deb \
-o portmaster.deb

# Install base packages
sudo apt update
sudo apt install -y build-essential nala fish curl git

# Install security apps
sudo nala install -y clamav clamav-base clamav-daemon clamav-freshclam
sudo nala install -y ./portmaster.deb || sudo apt -f install -y

# Cleanup
rm -f portmaster.deb

# Enabling Services
sudo systemctl enable --now clamav-freshclam
sudo systemctl enable --now clamav-daemon
sudo systemctl enable --now clamav-clamonacc  

# Configuring the clamd.conf file
sudo nano /etc/clamav/clamd.conf
# OnAccessIncludePath /home
# OnAccessExcludePath /home/user/Downloads
# OnAccessPrevention true

# Update ClamAV
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam

# Set default shell
chsh -s /usr/bin/fish

figlet "Setup Complete Log out and Log in to use fish" 2>/dev/null; or echo "Setup Complete Log out and Log in to use fish"
