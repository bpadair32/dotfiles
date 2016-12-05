#Aliases that are specific both to Mac and to current work environment

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
#Connect to AWS jump server
alias jump="ssh brad@jump.iqity.org"
