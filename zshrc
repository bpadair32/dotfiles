~/greeting.sh
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#Set path and make sure that coreutils is first in oder to override the built in MacOS utils
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin/:/opt/homebrew/opt/coreutils/libexec/gnubin:/usr/local/sbin:/usr/local/bin:$HOME/go/bin:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

#Setup $KUBECONFIG
export KUBECONFIG="${KUBECONFIG}:/Users/brad.adair/.kube/config-sellware-dev:/Users/brad.adair/.kube/config-colo:/Users/brad.adair/.kube/config-homelab"

# Path to your oh-my-zsh installation.
export ZSH=/Users/brad.adair/.oh-my-zsh

#Set ZSH theme
#ZSH_THEME="risto"
ZSH_THEME="powerlevel10k/powerlevel10k"
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(aws ansible git colorize vscode web-search)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

export JIRA_API_TOKEN="ATATT3xFfGF0kMQeenjLSiCirD_1QLhJGrZzrYAeFd0MjyHlrfXfjgIHfwH7tltW3y4OML1uSstcpJ78VbxyPAr8BptMP1QpkRHS9vgHhV68qvJCa93KeOJG5XF4aKvbTfQI1sysR23xwgGQQjo1oaxdcYBYIRyOpyMvGdzZ3Nmv_BLjkPtu-aY=766AA370"
#Make some basic functions more useful
alias cat="bat"
alias ls="ls -la --color"
alias ping="prettyping"
alias top="htop"
alias du="ncdu"
alias grep="grep --color=auto"
alias ps="procs"
alias python="python3"
alias pip="pip3"

#Quick directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias docs="cd ~/Documents"
alias temp="cd ~/Documents/temp"
alias adair="cd ~/Documents/Adair_Technology"
alias fbi="cd ~/Documents/FishBowl"
alias clients="cd ~/Documents/Adair_Technology/clients"

#Count files in directory
alias countFiles="echo $(ls -1 | wc -l)"

#Get external IP address
alias my-ip="curl ipinfo.io/ip"

#Automatically make parent directories when mkdir
alias mkdir="mkdir -pv"

#system maintenance
alias brewup='brew -v update && brew -v upgrade && brew -v upgrade --cask && brew -v cleanup --prune=5 && brew doctor'
alias cleanTemp="rm -rf ~/Documents/temp/*"
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update; sudo gem cleanup'
#Utilities
alias speedtest="speedtest-cli"

#Move files to trash instead of deleting
alias rm="trash"

#Scan the Wifi networks in the area
alias scanWifi="airport -s"

#Use tmux instead of screen
alias screen="tmux"

#Manage profile
alias editProf="nvim ~/.zshrc"
alias reload="source ~/.zshrc"

#Annoying commands I can never remember
alias spacer="defaults write com.apple.dock persistent-apps -array-add '{tile-type="spacer-tile";}' && killall Dock"
alias ports='netstat -a | grep -i "listen"'
alias backup='tar -zcvf $(date +%Y%m%d).tar.gz *'
alias extract='for i in *.gz; do tar xvf $i; done'

#Sometimes we need real OpenSSL and not the Libre version
alias ropenSSL="/usr/local/opt/openssl/bin/openssl"

#Other useful stuff
alias weather='function _weather() { \curl wttr.in/$i; }; _weather'
alias jsonpretty='function _jsonpretty() { python -m json.tool $1; } _jsonpretty'

function monitorProcess() {
  while true; do
    if ! pgrep -f $1; then
      echo "Process $1 has completed." | mail -s "Process Complete" brad@adair.tech
      break
    fi
    sleep 60
  done
}

function websiteStatus() {
  curl -s --head --request GET $1 | grep "200 OK"
}

eval $(thefuck --alias)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
  fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
