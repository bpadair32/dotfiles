#Make some basic functions more useful
alias ls="eza --long --icons --color --git"
alias top="htop"
alias du="ncdu"
alias grep="grep --color=auto"
alias python="python3"
alias pip="pip3"
alias vim="nvim"
alias cat="bat"
alias cd="z"
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
## if mac
alias cleanTemp="rm -rf ~/Documents/temp/*"

#Utilities
alias speedtest="speedtest-cli"

#Use tmux instead of screen
alias screen="tmux"

#Manage profile
alias editProf="nvim ~/.zshrc"
alias reload="source ~/.zshrc"

#Annoying commands I can never remember
alias ports='netstat -a | grep -i "listen"'
alias backup='tar -zcvf $(date +%Y%m%d).tar.gz *'
alias extract='for i in *.gz; do tar xvf $i; done'

#Other useful stuff
alias weather='function _weather() { \curl wttr.in/$i; }; _weather'

alias k=kubectl
alias tf=terraform
alias a=ansible
alias ap=ansible-playbook
alias fp='fzf --preview="bat --color=always {}"'
alias fnvim='nvim $(fzf --preview="bat --color=always {}")'
alias notes='nvim ~/Documents/Notes'

#Some git stuff
alias gundo='git reset --soft HEAD~1'
alias glog='git log --oneline -10 --graph --decorate'

#K8s shortcuts
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods =o wide'
alias klogs='kubectl logs -f'
alias kgs='kubectl get services'
alias kgi='kubectl get ingress'
