# Noblacklist
noblacklist ${HOME}/Allowed
noblacklist ${HOME}/.config/net.imput.helium
noblacklist ${HOME}/.cache/net.imput.helium

# Whitelisted Folders
whitelist ${HOME}/Allowed
whitelist ${HOME}/.config/net.imput.helium
whitelist ${HOME}/.cache/net.imput.helium

# Ignores
ignore noshm

# Fixes
# Input (Negate restrictions in chromium-common.profile)
ignore noinput
nodbus

# Fix Sandboxing
ignore apparmor

# IBus Specific Access
ignore noroot
noblacklist ${RUNUSER}/ibus
writable-run-user

# Networking (Negate netfilter in chromium-common.profile)
ignore netfilter
net host

