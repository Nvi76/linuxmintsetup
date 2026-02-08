#!/bin/bash
set -euo pipefail

# Ensure sudo access
sudo -v

# Backup directory
mkdir -p "$HOME/linuxmintsetup"

# Backup hosts
sudo cp /etc/hosts "$HOME/linuxmintsetup/hosts.backup"

# Download Portmaster
curl -fL https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.deb \
-o portmaster.deb

# Install base packages
sudo apt update
sudo apt install -y build-essential nala fish curl git

# Install security apps
sudo nala install -y clamav
sudo nala install -y ./portmaster.deb || sudo apt -f install -y

# Cleanup
rm -f portmaster.deb

# Update ClamAV
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam

# Set default shell
chsh -s "$(command -v fish)"

figlet "Setup Complete Log out and Log in to use fish" 2>/dev/null; or echo "Setup Complete Log out and Log in to use fish"
