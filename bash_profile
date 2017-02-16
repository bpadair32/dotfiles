###############
#BASH_PROFILE
###############

###############
#Defaults
###############

#Turn on colored output for term and ls
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

#Set default editor to VIM instead of VI
export EDITOR="/usr/local/bin/vim"

#Set PATH
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH:/usr/local/bin"

#Set some basics where the system defaults dont make sense
export BLOCKSIZE=1k
export GREP_OPTIONS='--color=auto'
shopt -s histappend
HISTFILESIZE=1000000
HISTSIZE=1000000
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
PROMPT_COMMAND='history -a'

#Set the prompt
export PS1="\[\e[0;36m\]\u@\[\e[m\e[0;32m\]\h:\[\e[m\e[0;34m\]\W:\[\e[m\`parse_git_branch\`\] "

##################
#Aliases
##################

#Make LS output more useful
alias ls="ls -la --color"

#Connect to main jump server
alias jump="ssh brad@jump.iqity.org"

#Connect to Cal jump server
alias calJump="ssh brad@cal-jump.iqity.org"

#Clear screen
alias cls="clear"

#ls sorted by most recent change at bottom
alias lsr="ls -lart --color"

#Quick directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias docs="cd ~/Documents"
alias temp="cd ~/Documents/temp"
alias projects="cd ~/Documents/Projects"
alias dotFiles="cd ~/Documents/dotfiles"
alias scripts="cd ~/Documents/scripts"
alias adair="cd ~/Documents/Personal/Projects/adair.tech"

#Count files in directory
alias countFiles="echo $(ls -1 | wc -l)"

#Make files of a certain size
alias make1mb="mkfile 1m ./1MB.dat"
alias make5mb="mkfile 5m ./5MB.dat"
alias make10mb="mkfile 10m ./10MB.dat"

#Get external IP address
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"

#Edit bash_profile
alias editProf="vim ~/.bash_profile"

#Reload bash_profile
alias reload="source ~/.bash_profile"

#Automatically make parent directories when mkdir
alias mkdir="mkdir -pv"

#See all current network socket connections
alias netCons='lsof -i'

#Connect to Cologix VPN, wait, connect to jump server
alias nagv="~/Documents/scripts/bash/colo.sh; sleep 2; ssh root@10.0.50.206"

#Connect to Cologix jump server
alias nag="ssh root@10.0.50.206"

#Connect to SCDE jump server
alias scj="ssh root@10.3.1.2"

#Connect to mobile project jump server
alias cmp='ssh -i ~/.ssh/brad_cmp.pem centos@52.205.78.172'

#VPN Connection scripts
alias vpn-colo='~/Documents/scripts/bash/colo.sh'
alias vpn-sh='~/Documents/scripts/bash/shvpn.sh'
alias vpn-dis='~/Documents/scripts/bash/discon.sh'

#Control viewing of hidden files and folders in Finder
alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'

#System maintenance
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
alias cleanTemp="rm -rf ~/Documents/temp/*"

#Utilities
alias speedtest="speedtest-cli"

#Move files to trash instead of deleting
alias rm="trash"

#Scan the Wifi networks in the area
alias scanWifi="airport -s"

#Lock system
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

#Connect to personal AWS server
alias yoda="ssh -i ~/.ssh/adair-tech.pem brad@52.15.192.168"

#Use tmux instead of screen
alias screen="tmux"

#########################
#Functions
#########################

#Simple file encryption with Blowfish
function blow()
{
    [ -z "$1" ] && echo 'Encrypt: blow FILE' && return 1
    openssl bf-cbc -salt -in "$1" -out "$1.bf"
}

#Simple file decryption with Blowfish
function fish()
{
    test -z "$1" -o -z "$2" && echo \
        'Decrypt: fish INFILE OUTFILE' && return 1
    openssl bf-cbc -d -salt -in "$1" -out "$2"
}

#Extract files
extract () {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
             esac
         else
             echo "'$1' is not a valid file"
         fi
    }

  #Allow "The Fuck" to work. This is command correction
    eval "$(thefuck --alias)"
    #Determine what branch you are on if directory is part of Git repo
    function parse_git_branch() {
        BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
        if [ ! "${BRANCH}" == "" ]
        then
            STAT=`parse_git_dirty`
            echo "[${BRANCH}${STAT}]"
        else
            echo ""
        fi
    }

    #Determine the current status of the Git repo if in one
    function parse_git_dirty {
        status=`git status 2>&1 | tee`
        dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
        untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
        ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
        newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
        renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
        deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
        bits=''
        if [ "${renamed}" == "0" ]; then
            bits=">${bits}"
        fi
        if [ "${ahead}" == "0" ]; then
            bits="*${bits}"
        fi
        if [ "${newfile}" == "0" ]; then
            bits="+${bits}"
        fi
        if [ "${untracked}" == "0" ]; then
            bits="?${bits}"
        fi
        if [ "${deleted}" == "0" ]; then
            bits="x${bits}"
        fi
        if [ "${dirty}" == "0" ]; then
            bits="!${bits}"
        fi
        if [ ! "${bits}" == "" ]; then
            echo " ${bits}"
        else
            echo ""
        fi
    }

#####################
#Env Variables
#####################
