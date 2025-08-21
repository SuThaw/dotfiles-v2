#!/usr/bin/env zsh
# ═══════════════════════════════════════════════════════════════════════════
#  Unified Zsh Configuration
#  Fast, modular, and feature-rich
# ═══════════════════════════════════════════════════════════════════════════

# ╭──────────────────────────────────────────────────────────╮
# │                    Performance First                     │
# ╰──────────────────────────────────────────────────────────╯

# Enable profiling (uncomment to debug slow startup)
# zmodload zsh/zprof

# ╭──────────────────────────────────────────────────────────╮
# │                      Core Settings                       │
# ╰──────────────────────────────────────────────────────────╯

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # Write timestamps
setopt INC_APPEND_HISTORY        # Write immediately
setopt SHARE_HISTORY             # Share between sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_VERIFY               # Show command before executing from history
setopt HIST_REDUCE_BLANKS        # Remove extra blanks

# Directory
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directories onto stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print directory stack

# Completion
setopt ALWAYS_TO_END             # Move cursor to end after completion
setopt AUTO_MENU                 # Show completion menu on tab press
setopt COMPLETE_IN_WORD          # Complete from both ends
setopt MENU_COMPLETE             # Cycle through completions

# Other
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive mode
setopt NO_BEEP                   # No beeping
setopt EXTENDED_GLOB             # Extended globbing

# ╭──────────────────────────────────────────────────────────╮
# │                         Paths                            │
# ╰──────────────────────────────────────────────────────────╯

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# ╭──────────────────────────────────────────────────────────╮
# │                    Environment Variables                 │
# ╰──────────────────────────────────────────────────────────╯

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Better ls colors
export LSCOLORS="ExGxFxdxCxDxDxhbadExEx"
export CLICOLOR=1

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 60%
  --layout=reverse
  --border=rounded
  --preview-window=right:50%
  --bind="ctrl-/:toggle-preview"
  --bind="ctrl-y:execute-silent(echo {} | pbcopy)+abort"
'

# ╭──────────────────────────────────────────────────────────╮
# │                      Completions                         │
# ╰──────────────────────────────────────────────────────────╯

# Initialize completions
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# ╭──────────────────────────────────────────────────────────╮
# │                        Aliases                           │
# ╰──────────────────────────────────────────────────────────╯

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# List files
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias l='eza -la --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
else
    alias l='ls -lah'
    alias ll='ls -lh'
    alias la='ls -lAh'
fi

# Better defaults
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'
alias grep='grep --color=auto'

# Git
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Editors
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias code='code .'

# tmux
alias t='tmux'
alias ta='tmux attach'
alias tls='tmux ls'
alias tn='tmux new -s'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Node/npm/yarn/pnpm/bun
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'

alias y='yarn'
alias yd='yarn dev'
alias yb='yarn build'

alias p='pnpm'
alias pd='pnpm dev'
alias pb='pnpm build'

alias b='bun'
alias bd='bun dev'
alias bb='bun build'
alias bx='bunx'

# Quick edits
alias zshrc='${EDITOR} ~/.zshrc'
alias vimrc='${EDITOR} ~/.config/nvim/init.lua'
alias tmuxconf='${EDITOR} ~/.config/tmux/tmux.conf'

# System
alias reload='source ~/.zshrc'
alias path='echo -e ${PATH//:/\\n}'
alias ports='lsof -PiTCP -sTCP:LISTEN'

# ╭──────────────────────────────────────────────────────────╮
# │                        Functions                         │
# ╰──────────────────────────────────────────────────────────╯

# Make directory and cd into it
mcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick project navigation
proj() {
    local dir
    dir=$(find ~/dev ~/projects ~/work -mindepth 1 -maxdepth 2 -type d 2>/dev/null | fzf)
    [ -n "$dir" ] && cd "$dir"
}

# Git clone and cd
gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Find and open in editor
fe() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always {}')
    [ -n "$file" ] && ${EDITOR} "$file"
}

# tmux session manager
tm() {
    [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
    if [ $1 ]; then
        tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1")
    else
        session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --height 40%)
        tmux $change -t "$session" || echo "No session selected"
    fi
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar e "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ╭──────────────────────────────────────────────────────────╮
# │                      Load Plugins                        │
# ╰──────────────────────────────────────────────────────────╯

# Load additional config files
for config in ~/.zsh/*.zsh; do
    [ -f "$config" ] && source "$config"
done

# Zsh plugins (install with: git clone <repo> ~/.zsh/<plugin-name>)
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ╭──────────────────────────────────────────────────────────╮
# │                     NVM (Lazy Load)                      │
# ╰──────────────────────────────────────────────────────────╯

# Lazy load NVM for faster startup
export NVM_DIR="$HOME/.nvm"

# Placeholder functions
nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm "$@"
}

node() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    node "$@"
}

npm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    npm "$@"
}

npx() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    npx "$@"
}

# ╭──────────────────────────────────────────────────────────╮
# │                    Starship Prompt                       │
# ╰──────────────────────────────────────────────────────────╯

# Initialize Starship (must be at the end)
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ╭──────────────────────────────────────────────────────────╮
# │                      Welcome Message                     │
# ╰──────────────────────────────────────────────────────────╯

# Optional: Show system info on start (comment out if too slow)
# command -v fastfetch &>/dev/null && fastfetch

# Profile (uncomment to debug slow startup)
# zprof
