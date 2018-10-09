# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/opt/coreutils/libexec/gnubin:/usr/local/sbin:$PATH:/usr/local/bin:/Users/bpadair/Documents/2Checkout/scs"

# Path to your oh-my-zsh installation.
export ZSH=/Users/bpadair/.oh-my-zsh
export SCS_CONF=/Users/bpadair/Documents/2Checkout/scs-config
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="risto"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

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
plugins=(aws osx sudo git colorize brew docker httpie npm sublime vscode web-search  zsh-autosuggestions) 

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='vim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#Make some basic functions more useful
alias cat="bat"
alias ls="ls -la --color"
alias nrs="npm run-script"
alias pip="pip3"
alias man="tldr"
alias ping="prettyping"
alias top="htop"
alias curl="http"
alias du="ncdu"
#Quick directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias docs="cd ~/Documents"
alias temp="cd ~/Documents/temp"
alias adair="cd ~/Documents/Adair\ Technology"
alias 2co="cd ~/Documents/2Checkout"
alias clients="cd ~/Documents/Adair\ Technology/clients"

#Count files in directory
alias countFiles="echo $(ls -1 | wc -l)"

#Make files of a certain size
alias make1mb="mkfile 1m ./1MB.dat"
alias make5mb="mkfile 5m ./5MB.dat"
alias make10mb="mkfile 10m ./10MB.dat"

#Get external IP address
alias my-ip="curl ipinfo.io/ip"

#Automatically make parent directories when mkdir
alias mkdir="mkdir -pv"

#VPN Connection scripts
alias vpn-dis='~/Documents/scripts/bash/discon.sh'
alias vpn-dc1='~/Documents/scripts/bash/vpn-dc1.sh'

#System maintenance
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
alias cleanTemp="rm -rf ~/Documents/temp/*"

#Utilities
alias speedtest="speedtest-cli"

#Move files to trash instead of deleting
alias rm="trash"

#Scan the Wifi networks in the area
alias scanWifi="airport -s"

#Use tmux instead of screen
alias screen="tmux"

#Manage profile
alias editProf="vim ~/.zshrc"
alias reload="source ~/.zshrc"

#Connect to bckup-01 jump server
alias bckup="ssh badair@192.168.1.243"

#manage hosts file
alias hosts-norm="sudo mv /etc/hosts /etc/hosts.2co && sudo mv /etc/hosts.ba /etc/hosts"
alias hosts-2co="sudo mv /etc/hosts /etc/hosts.ba && sudo mv /etc/hosts.2co /etc/hosts"
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
