#Aliases that are specific to Mac

#Change case sensitivity for TAB-Complete
alias cic="set completion-ignore-case On"
#Flush DNS
alias flushDNS="dscacheutil -flushcache"
#Control viewing of hidden files and folders in Finder
alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'
#Quick directory navigation
alias docs="cd ~/Documents"
alias temp="cd ~/Documents/temp"
alias projects="cd ~/Documents/Projects"
alias dotFiles="cd ~/Documents/dotfiles"
alias scripts="cd ~/Documents/scripts"
alias adair="cd ~/Documents/Personal/Projects/adair.tech"
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
alias yoda="ssh -i ~/.ssh/adair-tech.pem brad@52.15.95.69"
#Use tmux instead of screen
alias screen="tmux"
