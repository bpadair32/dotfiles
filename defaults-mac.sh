#####Default settings that are specific to Mac

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

#Show Archey when launching the terminal. This shows some nicely formatted sysinfo
archey
#Set the prompt
export PS1="\[\e[0;36m\]\u@\[\e[m\e[0;32m\]\h:\[\e[m\e[0;34m\]\W:\[\e[m\`parse_git_branch\`\] "
