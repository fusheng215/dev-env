# ============================================================
#  Git Bash configuration  (~/.bashrc)  — dev-env
#  Applied to: ~/.bashrc  (backed up to ~/.bashrc.bak first)
#  Optimized for productivity on Windows, portable to macOS/Linux.
# ============================================================

# ---------- shell options ----------
shopt -s histappend              # append to history, don't overwrite
shopt -s checkwinsize            # update LINES/COLUMNS after resize
shopt -s globstar                # ** recursive globbing
shopt -s autocd                  # type a dir name to cd into it
shopt -s cdspell                 # minor typo correction for cd

# ---------- history ----------
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups  # no dup lines, ignore space-prefixed
HISTIGNORE='ls:ll:la:cd:pwd:exit:clear:gs:gst:bg:fg:history'
# Convenient multi-terminal history sharing.
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# ---------- fzf (fuzzy finder) ----------
# Install via scoop install fzf (Windows) or brew (macOS).
if command -v fzf >/dev/null 2>&1; then
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=hl:33,fg+:235,bg+:236,hl+:33"
  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {} 2>/dev/null || cat {}'"
  export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"
fi

# ---------- starship prompt (cross-shell) ----------
# Install via: scoop install starship  (or curl -sS https://starship.rs/install.sh)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  # Fallback minimal prompt if starship isn't installed yet.
  PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
fi

# ---------- shared aliases ----------
if [ -f ~/.dotfiles-dev/aliases.sh ]; then
  source ~/.dotfiles-dev/aliases.sh
elif [ -f "$HOME/.dotfiles-dev/aliases.sh" ]; then
  source "$HOME/.dotfiles-dev/aliases.sh"
fi

# ---------- dev runtime version managers (if present) ----------
# fnm (Node) — cross-platform
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi
# nvm (Node, Windows classic) — uncomment if you use nvm-windows
# export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# pyenv (Python)
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  [ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi
# SDKMAN (Java / JVM)
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
# Go (assumes %USERPROFILE%\go)
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# ---------- useful exports ----------
export EDITOR='code --wait'
export VISUAL='code --wait'
export LESS='-R -F -X'
export CLICOLOR=1
export GREP_COLOR='1;35'

# ---------- welcome ----------
echo -e "\033[36mdev-env\033[0m ready — type \033[33maliases\033[0m or \033[33mreload\033[0m. Node $(node -v 2>/dev/null), Python $(python -V 2>&1 | cut -d' ' -f2)"
