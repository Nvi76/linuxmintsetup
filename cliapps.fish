#!/usr/bin/env fish

# Exit if any command fails
function on_error --on-event fish_prompt
    if test $status -ne 0
        echo "Script failed. Exiting."
        exit 1
    end
end

# Update system
sudo nala update -y
sudo nala upgrade -y

# Install Atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Setup Fish config directory
mkdir -p ~/.config/fish

# Append Atuin config
set config_file ~/.config/fish/config.fish

if not grep -q "atuin init fish" $config_file 2>/dev/null
    cat >> $config_file << 'EOF'

# Atuin setup
if status is-interactive
    set -gx ATUIN_NOBIND "true"
    atuin init fish | source
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
end
EOF
end

# Install Homebrew
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

# Add Homebrew to PATH (Fish way)
if not grep -q "brew shellenv" $config_file 2>/dev/null
    echo '' >> $config_file
    echo 'eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)' >> $config_file
end

# Apply brew env now
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)

# Reload config
source ~/.config/fish/config.fish

# Installation complete
figlet Installation Complete
