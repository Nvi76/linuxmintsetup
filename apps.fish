#!/usr/bin/env fish

# Update the system
sudo nala update -y
sudo nala upgrade -y

# Import Brave Browser’s repo keyring
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

# Add the Brave APT source list
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

# Download VS Code .deb
curl https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 --output vscode.deb

# Import VSCodium’s repo keyring
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

# Add VSCodium APT source
echo 'Types: deb
URIs: https://download.vscodium.com/debs
Suites: vscodium
Components: main
Architectures: amd64 arm64
Signed-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' | sudo tee /etc/apt/sources.list.d/vscodium.sources > /dev/null

# Update again after adding repos
sudo nala update -y
sudo nala upgrade -y

# Progress message
figlet "30% Complete"

# Install Flatpak apps
flatpak install flathub \
    com.rtosta.zapzap \
    org.kde.krita
    org.gimp.GIMP \
    
    --noninteractive

# 50%
figlet "50% Complete"

# Install RPM apps
sudo nala install \
    cava \
    codium \
    pipx \ 
    brave-browser \
    -y

# Installing packages
sudo nala install ./vscode.deb

# Update system
sudo nala update -y 
sudo nala upgrade -y

# Installing Homebrew Apps
brew install neovim thefuck

# Done
figlet Setup Complete. Enjoy your PC 
