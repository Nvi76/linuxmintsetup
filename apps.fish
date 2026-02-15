#!/usr/bin/env fish

# Update system
sudo nala update; or exit 1
sudo nala upgrade -y; or exit 1

# Import Brave keyring
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; or exit 1

# Add Brave repo
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
| sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null; or exit 1

# Add luanti's PPA
sudo add-apt-repository ppa:minetestdevs/stable

# Import VSCodium keyring
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
| gpg --dearmor \
| sudo tee /usr/share/keyrings/vscodium-archive-keyring.gpg >/dev/null; or exit 1

# Add VSCodium repo
printf "Types: deb
URIs: https://download.vscodium.com/debs
Suites: vscodium
Components: main
Architectures: amd64 arm64
Signed-by: /usr/share/keyrings/vscodium-archive-keyring.gpg
" | sudo tee /etc/apt/sources.list.d/vscodium.sources >/dev/null; or exit 1

# Download VS Code
curl -fL \
https://vscode.download.prss.microsoft.com/dbazure/download/stable/bdd88df003631aaa0bcbe057cb0a940b80a476fa/code_1.109.0-1770171879_amd64.deb \
-o vscode.deb; or exit 1

# Update after repos
sudo nala update; or exit 1
sudo nala upgrade -y; or exit 1

# Progress
figlet "30% Complete" 2>/dev/null; or echo "30% Complete"

# Install Flatpak apps
flatpak install com.rtosta.zapzap app.zen_browser.zen org.gimp.GIMP com.github.tchx84.Flatseal --noninteractive; or exit 1

# 50%
figlet "50% Complete" 2>/dev/null; or echo "50% Complete"

# Install packages
sudo nala install -y codium brave-browser minetest; or exit 1

# Install VS Code
sudo nala install ./vscode.deb -y; or exit 1

# Cleanup
rm -f vscode.deb

# Final update
sudo nala update; or exit 1
sudo nala upgrade -y; or exit 1

# Homebrew apps
if type -q brew
    brew install neovim fzf ranger btop thefuck trash-cli ffmpeg fastfetch
end

# Installing nvidia drivers
sudo nala install -y nvidia-driver-580

# Done
figlet "Setup Complete Enjoy Your PC" 2>/dev/null; or echo "Setup Complete Enjoy Your PC"Your PC"
