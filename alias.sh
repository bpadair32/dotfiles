#Make some basic functions more useful
alias ls="ls -la --color"
alias ping="prettyping"
alias top="htop"
alias du="ncdu"
alias grep="grep --color=auto"
alias python="python3"
alias pip="pip3"
alias vim="nvim"
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

alias k=kubectl
alias tf=terraform
alias a=ansible
alias ap=ansible-playbook
