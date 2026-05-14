#!/bin/bash
set -euo pipefail

clear
echo "================================================="
echo "           Setup & Config Firejail?"
echo "================================================="
echo "Do you want to install & config Firejail? (Recommended) WARNING will make system more secure but a bit harder to use (Still works though)"
echo "1) Yes, Setup Firejail (Laptop)"
echo "2) Yes, Setup Firejail (PC)"
echo "3) No, Don't Setup Firejail"

# Use ANSI escape codes for colored prompt
read -p $'\e[32mEnter choice [1-3]: \e[0m' choice

case $choice in
    '1')
        # Install necessary packages
        sudo add-apt-repository ppa:deki/firejail
        sudo nala update
        sudo nala install -y firejail firejail-profiles

        # Make folders
        sudo mkdir -p /etc/firejail/firecfg.d
        mkdir -p "$HOME/.config/firejail"
        mkdir -p "$HOME/Allowed"
        mkdir -p "$HOME/Allowed/AllowedCodes"
        mkdir -p "$HOME/Allowed/AllowedDocs"
        mkdir -p "$HOME/Allowed/AllowedPics"
        mkdir -p "$HOME/.local/share/applications"  
        mkdir -p "$HOME/.mozilla/firefox"
        
        # Copy configuration files (Laptop-specific configs)
        cp ~/linuxmintsetup/firejail-configs/Laptop/helium.profile ~/.config/firejail/helium.profile
        cp ~/linuxmintsetup/firejail-configs/Laptop/brave.local ~/.config/firejail/brave.local
        cp ~/linuxmintsetup/firejail-configs/Laptop/brave.local ~/.config/firejail/chromium.local
        cp ~/linuxmintsetup/firejail-configs/Laptop/firefox.local ~/.config/firejail/firefox.local
        cp ~/linuxmintsetup/firejail-configs/Laptop/librewolf.local ~/.config/firejail/librewolf.local

        echo "==========================================="
        echo "          Firejail Config Success          "
        echo "==========================================="

        # Do firecfg
        sudo firecfg

        # AppArmor Config
        sudo aa-enforce firejail-default || exit 1
        sudo systemctl restart apparmor
        sudo aa-status || exit 1
        ;;
    
    '2')
        # Install necessary packages
        sudo add-apt-repository ppa:deki/firejail
        sudo nala update
        sudo nala install -y firejail firejail-profiles

        # Make folders
        sudo mkdir -p /etc/firejail/firecfg.d
        mkdir -p "$HOME/.config/firejail"
        mkdir -p "$HOME/Allowed"
        mkdir -p "$HOME/Allowed/AllowedCodes"
        mkdir -p "$HOME/Allowed/AllowedDocs"
        mkdir -p "$HOME/Allowed/AllowedPics"
        mkdir -p "$HOME/.local/share/applications"
        mkdir -p "$HOME/.config/net.imput.helium"
        mkdir -p "$HOME/.cache/net.imput.helium"
        
        # Copy configuration files (PC-specific configs)
        cp ~/linuxmintsetup/firejail-configs/PC/helium.profile ~/.config/firejail/helium.profile
        cp ~/linuxmintsetup/firejail-configs/PC/brave.local ~/.config/firejail/brave.local
        cp ~/linuxmintsetup/firejail-configs/PC/brave.local ~/.config/firejail/chromium.local
        cp ~/linuxmintsetup/firejail-configs/PC/firefox.local ~/.config/firejail/firefox.local
        cp ~/linuxmintsetup/firejail-configs/PC/librewolf.local ~/.config/firejail/librewolf.local

        sudo tee /etc/firejail/firecfg.d/ExcludedApps.conf > /dev/null << 'EOF'
        !libreoffice
        !libreoffice-startcenter
        !org.libreoffice.LibreOffice
        !libreoffice-calc
        !libreoffice-writer
        !libreoffice-impress
        !libreoffice-draw
        !libreoffice-base
        !libreoffice-math
EOF

        echo "==========================================="
        echo "          Firejail Config Success          "
        echo "==========================================="

        # Do firecfg
        sudo firecfg

        # AppArmor Config
        sudo aa-enforce firejail-default || exit 1
        sudo systemctl restart apparmor
        sudo aa-status || exit 1
        ;;
    
    '3')
        clear
        echo "=================================================="
        echo "          Skipping Firejail Installation.         "
        echo "=================================================="
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

