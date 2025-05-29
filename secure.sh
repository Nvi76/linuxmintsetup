#!/bin/bash

set -euo pipefail

# Copying hosts file
sudo cp /etc/hosts ~/ubuntusetup 

# Installing hblock
curl -o /tmp/hblock 'https://raw.githubusercontent.com/hectorm/hblock/v3.5.1/hblock' \
  && echo 'd010cb9e0f3c644e9df3bfb387f42f7dbbffbbd481fb50c32683bbe71f994451  /tmp/hblock' | shasum -c \
  && sudo mv /tmp/hblock /usr/local/bin/hblock \
  && sudo chown 0:0 /usr/local/bin/hblock \
  && sudo chmod 755 /usr/local/bin/hblock && hblock 

# Installing security apps
sudo nano /etc/fail2ban/jail.local && sudo systemctl restart fail2ban && sudo apt install nala figlet fail2ban clamav clamav-daemon 

# Enabling services
sudo systemctl start fail2ban && sudo systemctl enable fail2ban && sudo systemctl enable clamav-daemon 

# Updating Clamav
sudo rm /var/log/clamav/freshclam.log && sudo freshclam
