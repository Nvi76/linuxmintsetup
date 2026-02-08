#!/usr/bin/env fish

# Update system
sudo nala update; or exit 1
sudo nala upgrade -y; or exit 1

# Install Cliapps
sudo nala install -y figlet fish curl git vulkan-tools build-essential python3-tk python3-distutils spipx; or exit 1

# Install Atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh; or exit 1

# Setup Fish config directory
mkdir -p ~/.config/fish

# Config file path
set config_file ~/.config/fish/config.fish
touch $config_file

# Append Atuin config if missing
if not grep -q "atuin init fish" $config_file 2>/dev/null

    printf '

# Atuin setup
if status is-interactive
    set -gx ATUIN_NOBIND true
    atuin init fish | source
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
end
' >> $config_file

end

# Install Homebrew
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash; or exit 1

# Add Homebrew to PATH if missing
if not grep -q "brew shellenv" $config_file 2>/dev/null

    printf '\n/home/linuxbrew/.linuxbrew/bin/brew shellenv | source\n' >> $config_file

end

# Apply brew env
/home/linuxbrew/.linuxbrew/bin/brew shellenv | source

# Reload config
source ~/.config/fish/config.fish

# Done
figlet "Setup Complete" 2>/dev/null; or echo "Setup Complete"
