#!/bin/bash 

set -euo pipefail

# Updates the system
sudo nala update && sudo nala upgrade

# Installing Atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Setting up atuin
mkdir -p ~/.config/fish

# Append Atuin config to fish config
cat >> ~/.config/fish/config.fish << 'EOF'
if status is-interactive
    set -gx ATUIN_NOBIND "true"
    atuin init fish | source
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
end
EOF

# Installing Homebrew
sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash  

# Adding Homebrew to shell PATH
 echo >> ~/.config/fish/config.fish
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"' >> ~/.config/fish/config.fish
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"

# Updating fish
source ~/.config/fish/config.fish