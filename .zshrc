#Run my greeting script
~/greeting.sh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#Set path and make sure that coreutils is first in oder to override the built in MacOS utils
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin/:/opt/homebrew/opt/coreutils/libexec/gnubin:/usr/local/sbin:/usr/local/bin:$HOME/go/bin:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

#Setup $KUBECONFIG
export KUBECONFIG="/Users/${USER}/.kube/config-hosting:/Users/${USER}/.kube/config-bold-reports:/Users/${USER}/.kube/config-sellware-qa:/Users/${USER}/.kube/config-sellware-dev:/Users/${USER}/.kube/config-colo:/Users/${USER}/.kube/config-homelab:/Users/${USER}/.kube/config-sellware-stage:/Users/${USER}/.kube/config-sellware-prod"
# Path to oh-my-zsh installation.
export ZSH=/Users/${USER}/.oh-my-zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

HYPHEN_INSENSITIVE="true"

export UPDATE_ZSH_DAYS=7

ENABLE_CORRECTION="true"

plugins=(aws ansible git colorize sudo web-search)

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export JIRA_API_TOKEN="ATATT3xFfGF0kMQeenjLSiCirD_1QLhJGrZzrYAeFd0MjyHlrfXfjgIHfwH7tltW3y4OML1uSstcpJ78VbxyPAr8BptMP1QpkRHS9vgHhV68qvJCa93KeOJG5XF4aKvbTfQI1sysR23xwgGQQjo1oaxdcYBYIRyOpyMvGdzZ3Nmv_BLjkPtu-aY=766AA370"

source ~/alias.sh
source ~/functions.sh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source <(fzf --zsh)
# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}
# ----- Bat (better cat) -----

export BAT_THEME=GitHub
# ---- Eza (better ls) -----

alias ls="eza --color=always --long --git --icons=always"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}
# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
