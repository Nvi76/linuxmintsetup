#!/bin/bash

sudo apt update -y && sudo apt upgrade -y && sudo snap refresh && sudo snap install firefox thunderbird && sudo apt install nala -y && sudo nala install nvidia-driver-550 ubuntu-gnome-desktop ubuntu-desktop plymouth plymouth-themes* network-manager -y && sudo systemctl start NetworkManager.service && sudo systemctl enable NetworkManager.service && ./cliapps.sh && ./apps.sh && sudo update-alternatives --config default.plymouth && sudo nano /etc/gdm3/custom.conf && sudo nano /etc/default/grub && sudo update-grub && 
sudo update-initramfs -u


