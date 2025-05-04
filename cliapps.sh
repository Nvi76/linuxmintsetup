#!/bin/bash 

sudo nala install build-essential nautilus-extension-gnome-terminal -y && curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && sudo apt-get install build-essential -y
