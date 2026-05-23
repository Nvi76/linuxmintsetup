# Noblacklist
noblacklist ${HOME}/Allowed
noblacklist ${HOME}/.config/net.imput.helium
noblacklist ${HOME}/.cache/net.imput.helium

# Whitelisted Folders
whitelist ${HOME}/Allowed
whitelist ${HOME}/.config/net.imput.helium
whitelist ${HOME}/.cache/net.imput.helium

# Web Apps (Linux Mint ice)
noblacklist ${HOME}/.local/share/ice
whitelist ${HOME}/.local/share/ice

# Ignores
ignore noshm

# Fixes
# Input (Negate restrictions in chromium-common.profile)
ignore noinput
nodbus

# IBus Specific Access
ignore noroot
noblacklist ${RUNUSER}/ibus
writable-run-user

# Networking (Negate netfilter in chromium-common.profile)
ignore netfilter
net host

