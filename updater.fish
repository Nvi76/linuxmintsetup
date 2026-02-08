#!/usr/bin/env fish

# Update ClamAV
sudo freshclam; or exit 1

# Update system
sudo nala update; or exit 1
sudo nala upgrade -y; or exit 1

# Update Flatpak apps
flatpak update -y; or exit 1

# Update Homebrew (if installed)
if type -q brew
    brew update; or exit 1
    brew upgrade; or exit 1
end

# Done
figlet "All Updates Completed" 2>/dev/null; or echo "All Updates Completed"
