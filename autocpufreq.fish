#!/usr/bin/env fish

# Change dir to home
cd ~

# Cloning the directory 
git clone https://github.com/AdnanHodzic/auto-cpufreq.git

# Change to the folder
cd auto-cpufreq; or exit 1

# Run the installer
sudo ./auto-cpufreq-installer
