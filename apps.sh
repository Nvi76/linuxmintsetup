#!/bin/bash

set -euo pipefail

# Updates the system
sudo apt update -y && sudo apt upgrade -y

# Installing snap applications
sudo snap refresh && sudo snap install code --classic && sudo snap install codium --classic && sudo snap install firmware-updater qbittorrent-arnatious notion-desktop element-desktop varia discord vlc telegram-desktop && sudo snap connect varia:shutdown 

# Importing signal's keyring and repo
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg &&
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null && echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\ sudo tee /etc/apt/sources.list.d/signal-xenial.list

# Downloading anytype
curl https://anytype-release.fra1.cdn.digitaloceanspaces.com/anytype_0.46.8_amd64.deb --output anytype.deb

# Importing brave browser's repo
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list 

# Updates the system
sudo apt update -y && sudo apt upgrade -y 

# Installing deb packages
sudo nala install btop epiphany-browser flatpak neovim kitty kakoune nautilus-extension-gnome-terminal signal-desktop gnome-software-plugin-flatpak gnome-shell-extension-manager gnome-weather gnome-tweaks gnome-maps gnome-calendar build-essential ubuntu-restricted-extras timeshift libreoffice brave-browser -y 

# 40%
figlet 40% Complete

# Downloading Cursor
cd ~ && mkdir Appimages && cd ~/Appimages && curl https://downloads.cursor.com/production/96e5b01ca25f8fbd4c4c10bc69b15f6228c80771/linux/x64/Cursor-0.50.5-x86_64.AppImage -- output Cursor.Appimage && cd ~/ubuntusetup

# Installing locally Downloaded deb packages
sudo nala install ./anytype.deb

# Importing flathub's repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install flathub com.rtosta.zapzap network.loki.Session re.sonny.Junction net.mullvad.MullvadBrowser net.codelogistics.webapps io.frama.tractor.carburetor org.torproject.torbrowser-launcher com.protonvpn.www io.github.fkinoshita.Telegraph app.zen_browser.zen  com.github.PintaProject.Pinta com.github.tchx84.Flatseal me.proton.Pass io.github.josephmawa.Bella org.onlyoffice.desktopeditors io.github.giantpinkrobots.flatsweep org.gnome.design.Lorem org.inkscape.Inkscape com.logseq.Logseq org.cryptomator.Cryptomator dev.qwery.AddWater com.belmoussaoui.Obfuscate org.localsend.localsend_app io.github._0xzer0x.qurancompanion org.gimp.GIMP it.mijorus.gearlever --noninteractive

# 85%
figlet 95% Complete

# Installing Homebrew packages (make sure to have homebrew already installed)
brew install gcc thefuck fzf ranger mailsy 

# 100%
figlet 100% Complete
