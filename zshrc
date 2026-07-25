#Bootstrap antidote if we dont already have it
if [[ ! -d "${ANTIDOTE_HOME:-$HOME/.local/share/antidote}" ]] then
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${ANTIDOTE_HOME:-$HOME/.local/share/antidote}"
fi

# Set path
export PATH=$PATH:~/.local/scripts:~/.local/bin:~/bin:${CARGO_HOME:-$HOME/.local/share/cargo}/bin:~/go/bin:${KREW_ROOT:-$HOME/.local/share/krew}/bin:${BUN_INSTALL:-$HOME/.local/bun}/bin

# Run my greeting script before the instant prompt
~/greeting.sh

#Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source the p10k config
[[ ! -f "${ZDOTDIR:-$HOME}/.p10k.zsh" ]] || source "${ZDOTDIR:-$HOME}/.p10k.zsh"

# Init antidote and load plugins
source "${ANTIDOTE_HOME:-$HOME/.local/share/antidote}/antidote.zsh"
antidote load "${ZDOTDIR:-$HOME/.config/zsh}/zsh_plugins.txt"

export EDITOR="nvim"
export KUBECONFIG=~/.kube/homelab.yaml

# Load zsh completions
autoload -U compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# Setup history
HISTSIZE=5000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#Keybinds
bindkey -v 
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Make completions case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Use color in completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# No default menu for completions as we are using fzf
zstyle ':completions:*' menu no

# Preview completions in fzf
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
# Include fzf
eval "$(fzf --zsh)"

# Configure fzf 
export FZF_DEFAULT_COMMAND='fd . --hidden --exclude ".git"'
export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 40% --preview='bat -p --color=always {}'"
export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview"
# Include zoxide
eval "$(zoxide init zsh)"

#Include my aliases and functions
source ~/alias.sh
source ~/functions.sh

. "$HOME/.local/bin/env"

# opencode
export PATH=/home/bpadair/.opencode/bin:$PATH

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# bun completions
[ -s "${BUN_INSTALL:-$HOME/.local/bun}/_bun" ] && source "${BUN_INSTALL:-$HOME/.local/bun}/_bun"
