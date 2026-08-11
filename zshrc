# XDG base directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Redirect tool config/data/cache to XDG locations
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export ANSIBLE_HOME="$XDG_DATA_HOME/ansible"
export ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/ansible.cfg"
export ANSIBLE_GALAXY_CACHE_DIR="$XDG_DATA_HOME/ansible/galaxy_cache"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export TASKRC="$XDG_CONFIG_HOME/task/taskrc"
export TASKDATA="$XDG_DATA_HOME/task"
export TALOSCONFIG="$XDG_CONFIG_HOME/talos/config"
export MYSQL_HISTFILE="$XDG_STATE_HOME/mysql/history"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

#Bootstrap antidote if we dont already have it
if [[ ! -d "${ZDOTDIR:-$HOME}/.antidote" ]] then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
fi

# Set path
export PATH=$PATH:~/.local/scripts:~/.local/bin:~/bin:$CARGO_HOME/bin:~/go/bin:$HOME/.krew/bin

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
export KUBECONFIG="$XDG_CONFIG_HOME/kube/homelab.yaml"

# Load zsh completions (cache compdump under XDG_CACHE_HOME)
autoload -U compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Setup history
HISTSIZE=5000
HISTFILE="$XDG_STATE_HOME/zsh/history"
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

# Run a throwaway debug pod that satisfies PodSecurity "restricted".
# Usage: kdebug [image] [namespace]
#   kdebug                          # busybox in current namespace
#   kdebug nicolaka/netshoot        # netshoot
#   kdebug busybox mynamespace      # busybox in mynamespace
kdebug() {
  local image="${1:-busybox}"
  local ns="${2:-}"
  local name="debug-${image##*/}"
  name="${name%%:*}"
  local nsflag=()
  [[ -n "$ns" ]] && nsflag=(-n "$ns")

  kubectl run -it --rm "$name" --image="$image" --restart=Never "${nsflag[@]}" \
    --override-type=strategic \
    --overrides="{
      \"spec\": {
        \"securityContext\": {
          \"runAsNonRoot\": true,
          \"runAsUser\": 1000,
          \"seccompProfile\": {\"type\": \"RuntimeDefault\"}
        },
        \"containers\": [{
          \"name\": \"$name\",
          \"image\": \"$image\",
          \"stdin\": true,
          \"tty\": true,
          \"args\": [\"sh\"],
          \"securityContext\": {
            \"allowPrivilegeEscalation\": false,
            \"capabilities\": {\"drop\": [\"ALL\"]}
          }
        }]
      }
    }" -- sh
}

