#!/usr/bin/env fish

# Add PPA'S
sudo add-apt-repository universe -y; or exit 1
sudo add-apt-repository ppa:agornostal/ulauncher -y; or exit 1

# Update system
sudo nala update; or exit 1
sudo nala upgrade -y; or exit 1

# Install Cliapps
sudo nala install -y figlet fish curl git vulkan-tools os-prober build-essential python3-tk python3-distutils-extra pipx mesa-utils gnupg copyq cava ulauncher; or exit 1

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

# Ensure the config directory exists
if not test -d ~/.config/fish
    mkdir -p ~/.config/fish
end

# Append the Homebrew setup to Fish config
echo 'eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)' >> ~/.config/fish/config.fish

# Evaluate the Homebrew environment in the current session
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)   

# Apply brew env
/home/linuxbrew/.linuxbrew/bin/brew shellenv | source

# Reload config
source ~/.config/fish/config.fish

# Done
figlet "Setup Complete" 2>/dev/null; or echo "Setup Complete"
