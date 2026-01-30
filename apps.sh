#!/bin/bash

set -euo pipefail

# Updates the system
sudo apt update -y && sudo apt upgrade -y

# Importing brave browser's repo
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list 

# Importing vscodium's repo
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

# Importing vscodium's repo 
echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
| sudo tee /etc/apt/sources.list.d/vscodium.sources

# Updates the system
sudo apt update -y && sudo apt upgrade -y

# 30%
figlet 30% Complete

# Installing deb apps 
sudo nala install codium brave-browser -y 

# Install portmaster && vscode yourself

# 65%
figlet 65% Complete

# Installing flatpak apps
flatpak install flathub com.rtosta.zapzap   --noninteractive

# 85%
figlet 85% Complete

# Installing Homebrew packages (make sure to have homebrew already installed)
brew install gcc thefuck fzf ranger mailsy 

# 100%
figlet 100% Complete
