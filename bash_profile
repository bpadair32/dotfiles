#####Set Path#####
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH:/usr/local/bin"
#####Set sane defaults#####
export BLOCKSIZE=1k
export GREP_OPTIONS='--color=auto'
shopt -s histappend
HISTFILESIZE=1000000
HISTSIZE=1000000
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
PROMPT_COMMAND='history -a'
#####Show Archey#####
archey
#####Env variables needed for using ansible with AWS
export AWS_ACCESS_KEY_ID='AKIAJQGR6THYMEHH247Q'
export AWS_SECRET_ACCESS_KEY='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'
#####Color terminal#####
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

#####Some other helpful exports
export EDITOR="/usr/local/bin/vim"
#####Aliases#####
alias ls="ls -la --color"
alias nagv="~/Documents/scripts/bash/colo.sh; sleep 2; ssh root@10.0.50.206"
alias nag="ssh root@10.0.50.206"
alias cls="clear"
alias scj="ssh root@10.3.1.2"
alias lsr="ls -lart --color" 
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias cic="set completion-ignore-case On"
alias countFiles="echo $(ls -1 | wc -l)"
alias make1mb="mkfile 1m ./1MB.dat"
alias make5mb="mkfile 5m ./5MB.dat"
alias make10mb="mkfile 10m ./10MB.dat"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias flushDNS="dscacheutil -flushcache"
alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'
alias cmp='ssh -i ~/.ssh/brad_cmp.pem centos@52.205.78.172'
alias vpn-colo='~/Documents/scripts/bash/colo.sh'
alias vpn-sh='~/Documents/scripts/bash/shvpn.sh'
alias vpn-dis='~/Documents/scripts/bash/discon.sh'
alias docs="cd ~/Documents"
alias temp="cd ~/Documents/temp"
alias projects="cd ~/Documents/Projects"
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
alias editProf="vim ~/.bash_profile"
alias reload="source ~/.bash_profile"
alias speedtest="speedtest-cli"
alias jump="ssh brad@jump.iqity.org"
alias cleanTemp="rm -rf ~/Documents/temp/*"
alias rm="trash"
alias scanWifi="airport -s"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias mkdir="mkdir -pv"
alias netCons='lsof -i'
alias dotFiles="cd ~/Documents/dotfiles"
#####Useful functions#####
#Simple command correction
eval "$(thefuck --alias)"
#Simple blowfish encryption
function blow()
{
    [ -z "$1" ] && echo 'Encrypt: blow FILE' && return 1
    openssl bf-cbc -salt -in "$1" -out "$1.bf"
}
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


#####Set Prompt#####
# get current branch in git repo
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

# get current status of git repo
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

export PS1="\e[0;36m\u@\e[m\e[0;32m\h:\e[m\e[0;34m\W:\e[m\`parse_git_branch\` "
