#!/usr/bin/env fish

# Update system
sudo nala update -y
and sudo nala upgrade -y

# Update Flatpak apps
flatpak update -y

# Update Homebrew
brew update
and brew upgrade

# Update ClamAV
sudo freshclam

# Update complete
figlet Update Complete
