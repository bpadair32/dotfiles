#####General aliases that work on both Mac and Linux

#Connect to jump server
alias jump="ssh brad@jump.iqity.org"
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
