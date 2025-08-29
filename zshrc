#Bootstrap antidote if we dont already have it
if [[ ! -d "${ZDOTDIR:-$HOME}/.antidote" ]] then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
fi 

# Set path
export PATH=$PATH:~/.local/scripts:~/.local/bin:~/bin:~/.cargo/bin:~/go/bin:$HOME/.krew/bin

# Run my greeting script before the instant prompt
~/greeting.sh

#Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source the p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Init antidote and load plugins
source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
antidote load "${ZDOTDIR:-$HOME}/.zsh_plugins.txt"

export EDITOR="nvim"
export KUBECONFIG=~/.kube/homelab.yaml

# Load zsh completions
autoload -U compinit && compinit

# Setup history
HISTSIZE=5000
HISTFILE=~/.zsh_history
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
# Include zoxide
eval "$(zoxide init zsh)"

#Include my aliases and functions
source ~/alias.sh
source ~/functions.sh

. "$HOME/.local/bin/env"
