#!/bin/bash

sudo cp /etc/hosts ~/ubuntusetup && curl -o /tmp/hblock 'https://raw.githubusercontent.com/hectorm/hblock/v3.5.1/hblock' \
  && echo 'd010cb9e0f3c644e9df3bfb387f42f7dbbffbbd481fb50c32683bbe71f994451  /tmp/hblock' | shasum -c \
  && sudo mv /tmp/hblock /usr/local/bin/hblock \
  && sudo chown 0:0 /usr/local/bin/hblock \
  && sudo chmod 755 /usr/local/bin/hblock && hblock && sudo nala install fail2ban &&  sudo systemctl start fail2ban && sudo systemctl enable fail2ban && sudo nano /etc/fail2ban/jail.local && sudo systemctl restart fail2ban && sudo nala install clamav clamav-daemon && sudo systemctl enable clamav-daemon
  
