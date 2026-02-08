#!/bin/bash

set -euo pipefail

# Create backup directory if missing
mkdir -p ~/linuxmintsetup

# Copy hosts file
sudo cp /etc/hosts ~/linuxmintsetup/hosts.backup

# Download Portmaster
curl -L https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.deb \
-o portmaster.deb

# Install essential packages
sudo apt update
sudo apt install -y build-essential nala fish curl git

# Install security apps
sudo nala install -y clamav
sudo nala install -y ./portmaster.deb

# Update ClamAV
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam

# Change default shell to fish
chsh -s /usr/bin/fish
