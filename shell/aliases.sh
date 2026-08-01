#!/usr/bin/env bash
# ============================================================
#  Shared shell aliases & functions  (sourced by .bashrc)
#  Kept shell-agnostic where possible; the PowerShell profile
#  mirrors these as native aliases.
# ============================================================

# ---------- navigation ----------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# eza (modern `ls`) — falls back to plain `ls` if not installed.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --color=auto'
  alias ll='eza -lh --group-directories-first --git'
  alias la='eza -lha --group-directories-first --git'
  alias lt='eza --tree --level=2 -I ".git|node_modules|dist|build|target"'
  alias tree='eza --tree -I ".git|node_modules|dist|build|target"'
else
  alias ls='ls -h --group-directories-first --color=auto'
  alias ll='ls -lh --group-directories-first'
  alias la='ls -lha --group-directories-first'
  alias tree='tree -C -I "node_modules|.git|dist|build|target|bin|obj"'
fi

# ---------- git (short) ----------
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch -vv'
alias gl='git log --graph --oneline --decorate -10'
alias glog='git log --graph --pretty=format:"%C(auto)%h%d %C(cyan)%an %C(green)%ar%C(reset) %s"'
alias gp='git push'
alias gpl='git pull --rebase --autostash'
alias gf='git fetch --all --prune'
alias gr='git restore'
alias grs='git restore --staged'
alias gst='git stash'
alias gstp='git stash pop'

# ---------- node / npm / pnpm ----------
alias n='npm'
alias nr='npm run'
alias ni='npm install'
alias nid='npm install -D'
alias nx='npx'
alias p='pnpm'
alias pr='pnpm run'
alias pi='pnpm install'
alias py='python'
alias py3='python3'
alias pip='pip'
alias serve='python -m http.server 8000'

# ---------- docker / k8s ----------
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias k='kubectl'
alias kx='kubectl exec -it'

# ---------- misc ----------
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ip='ip -c'
alias h='history'

# ---------- modern CLI replacements (graceful fallback) ----------
# bat: syntax-highlighted, git-aware `cat`
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi
# ripgrep: recursive search that respects .gitignore
if command -v rg >/dev/null 2>&1; then
  alias rg='rg --hidden --glob "!.git"'
fi
# fd: simple, fast `find`
if command -v fd >/dev/null 2>&1; then
  alias f='fd'
fi
alias j='jobs -l'
alias c='clear'
alias e='exit'
alias path='echo -e ${PATH//:/\\n}'
alias reload='source ~/.bashrc'
alias hostfile='code /c/Windows/System32/drivers/etc/hosts'

# ---------- helper functions ----------
# Create a dir and cd into it.
mkcd() { mkdir -p "$1" && cd "$1" || return; }

# Quick git repo init with main branch + first commit.
ginit() {
  git init -b main && git add -A && git commit -m "Initial commit" && echo "Repo initialized on 'main'."
}

# Fuzzy-find and cd into a subdirectory.
fcd() {
  local dir
  dir=$(find . -type d -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | fzf --height 40% --reverse) && cd "$dir" || return
}

# Fuzzy-search git branches and check them out.
gcof() {
  local br
  br=$(git branch --format='%(refname:short)' | fzf --height 40% --reverse --preview 'git log --oneline -10 {}') && git checkout "$br" || return
}

# Show a file's git history and fuzzy-pick a commit to view.
glogf() {
  git log --oneline --color=always "$@" | fzf --height 50% --reverse --ansi --preview 'git show --color=always {1}' | awk '{print $1}'
}

# Extract almost any archive.
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.zst)     unzstd "$1" ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Pretty-print JSON from clipboard or file.
jqf() { jq . "${1:-/dev/stdin}"; }
