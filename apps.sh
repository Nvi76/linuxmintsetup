#!/bin/bash

set -euo pipefail

# Updates the system
sudo apt update -y && sudo apt upgrade -y

# Installing snap applications
sudo snap refresh && sudo snap install code --classic && sudo snap install codium --classic && sudo snap install signal-desktop qbittorrent-arnatious notion-desktop element-desktop varia discord telegram-desktop && sudo snap connect varia:shutdown 

# Importing brave browser's repo
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list 

# Updates the system
sudo apt update -y && sudo apt upgrade -y 

# Installing deb apps
sudo nala install btop epiphany-browser flatpak neovim kakoune nautilus-extension-gnome-terminal gnome-software-plugin-flatpak gnome-shell-extension-manager vlc gnome-weather gnome-tweaks gnome-maps gnome-calendar build-essential ubuntu-restricted-extras timeshift libreoffice brave-browser -y 

# Install cursor, anytyp, and chrome yourself yourself

# 40%
figlet 40% Complete

# Importing flathub's repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install flathub com.rtosta.zapzap org.wezfurlong.wezterm network.loki.Session re.sonny.Junction net.mullvad.MullvadBrowser net.codelogistics.webapps io.frama.tractor.carburetor org.torproject.torbrowser-launcher com.protonvpn.www io.github.fkinoshita.Telegraph app.zen_browser.zen  com.github.PintaProject.Pinta com.github.tchx84.Flatseal me.proton.Pass io.github.josephmawa.Bella org.onlyoffice.desktopeditors io.github.giantpinkrobots.flatsweep org.gnome.design.Lorem org.inkscape.Inkscape com.logseq.Logseq org.cryptomator.Cryptomator dev.qwery.AddWater com.belmoussaoui.Obfuscate org.localsend.localsend_app io.github._0xzer0x.qurancompanion org.gimp.GIMP it.mijorus.gearlever --noninteractive

# 85%
figlet 95% Complete

# Installing Homebrew packages (make sure to have homebrew already installed)
brew install gcc thefuck fzf ranger mailsy 

# 100%
figlet 100% Complete
