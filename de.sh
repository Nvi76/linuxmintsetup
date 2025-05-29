#!/bin/bash

set -euo pipefail

# Elevating file permissions
chmod +x secure.sh && chmod +x updater.sh && chmod +x apps.sh && chmod +x cliapps.sh && chmod +x ollama.sh

# Updating the syste,
sudo apt update -y && sudo apt upgrade -y 

# Updating and installing core snap apps
sudo snap refresh && sudo snap install firefox thunderbird snap-center && sudo apt install git curl nala -y && sudo nala install ubuntu-gnome-desktop ubuntu-desktop plymouth plymouth-themes* network-manager -y && sudo systemctl start NetworkManager.service && sudo systemctl enable NetworkManager.service && sudo systemctl disable systemd-networkd-wait-online.service && sudo systemctl disable NetworkManager-wait-online.service && sudo update-alternatives --config default.plymouth && sudo nano /etc/gdm3/custom.conf && sudo nano /etc/default/grub && sudo update-grub && 
sudo update-initramfs -u
