# Linux Mint Setup
Setup and configuration script for linux mint.

# 1. Git Manual
1) **Git & GitHub Setup**

After running `secure.sh`, an SSH key is generated automatically.
If you need to do it manually:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

2) **Add the key to GitHub**

1. Print your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. Copy the output
3. Go to GitHub → **Settings** → **SSH and GPG keys** → **New SSH key**
4. Paste the key and save

3) **First-time push (new repo)**

```bash
cd ~/Projects/Scripts/linuxmintsetup
git remote add origin git@github.com:Nvi76/linuxmintsetup.git # this is if there's no origin yet
git init
git remote set-url origin git@github.com:Nvi76/linuxmintsetup.git
git add .
git commit -m "Initial setup"
git push -u origin main
```

4) **Subsequent pushes**

```bash
cd ~/Projects/Scripts/linuxmintsetup
git add .
git commit -m "description of changes"
git push
```

# 2. Shell Configs
**Fish**
```
if status is-interactive
    set -gx ATUIN_NOBIND true
    atuin init fish | source

    bind \e\[A _atuin_bind_up
    bind \cr _atuin_search

    if bind -M insert >/dev/null 2>&1
        bind -M insert \e\[A _atuin_bind_up
        bind -M insert \cr _atuin_search
    end

    bind \e\[3\;5~ kill-word
    bind \cH backward-kill-word
end

# Aliases
alias lsa "ls -a "
alias update "~/.updater.sh "
alias scan "clamscan -r "
alias trm "trash-put "
alias trestore "trash-restore "
alias tbin "trash-empty "
alias listt "trash-list "
alias copy "wl-copy < "
alias paste "wl-paste > "
alias rkscan "sudo rkhunter --check --sk "
alias kate "flatpak run org.kde.kate "

# Homebrew
if test -f /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

# Thefuck
if command -v thefuck >/dev/null
    thefuck --alias | source
end
```

**Bash**
```
# === apps.sh managed block - do not edit manually ===
eval "$(atuin init bash)"

[ -f "$HOME/.local/share/blesh/ble.sh" ] && source "$HOME/.local/share/blesh/ble.sh"

alias lsa="ls -a"
alias update="~/.updater.sh"
alias scan="clamscan -r"
alias trm="trash-put"
alias trestore="trash-restore"
alias tbin="trash-empty"
alias listt="trash-list"
alias copy="wl-copy <"
alias paste="wl-paste >"
alias rkscan="sudo rkhunter --check --sk"
alias kate="flatpak run org.kde.kate"

# Homebrew
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Thefuck
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

# OpenCode
export PATH="$PATH:$HOME/.opencode/bin"
if command -v opencode &>/dev/null; then
    source <(opencode completion bash 2>/dev/null) 2>/dev/null || true
fi

# === end of apps.sh block ===
```

**Zsh**
```
# === apps.sh managed block - do not edit manually ===
eval "$(atuin init zsh)"

alias lsa="ls -a"
alias update="~/.updater.sh"
alias scan="clamscan -r"
alias trm="trash-put"
alias trestore="trash-restore"
alias tbin="trash-empty"
alias listt="trash-list"
alias copy="wl-copy <"
alias paste="wl-paste >"
alias rkscan="sudo rkhunter --check --sk"
alias kate="flatpak run org.kde.kate"

if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

# Opencode
export PATH="$PATH:$HOME/.opencode/bin"
if command -v opencode &>/dev/null; then
    source <(opencode completion zsh 2>/dev/null) 2>/dev/null || true
fi

# === end of apps.sh block ===
```

# 2. Ollama Service Fix
**If ollama.service is not working properly try to run:**
```
sudo mkdir -p /usr/share/ollama && sudo chown ollama:ollama /usr/share/ollama
sudo systemctl restart ollama
```

# 3. Custom Search Engines
```
Arch: https://archlinux.org/packages/?q=%s (archs)
Aur: https://aur.archlinux.org/packages?O=0&K=%s (aurs)
YouTube Search: https://www.youtube.com/search?q=%s (ytu)
Nixpkg Search: https://search.nixos.org/packages?channel=25.11&query=%s (nixpkg)
Brave Search: https://search.brave.com/search?q=%s
Brave Search Ask: https://search.brave.com/search?q=%s
Startpage: https://startpage.com/search?q=%s
Ecosia: https://ecosia.org/search?q=%s
```
