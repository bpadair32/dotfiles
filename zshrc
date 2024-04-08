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

source ./alias.sh
source ./functions.sh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
