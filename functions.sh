function csv_pretty() {
	if [ -z "$1"]; then
		echo "Usage: csv_pretty <file.csv>"
	else
		cat "$1" | column -s, -t | less -F -S -X -K
	fi
}

function recently_modified() {
	recent_file=$(ls -t | head -n1)
	echo "Most recently modified file is: $recent_file"
}

function mem_hog() {
	ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
}

function monitorProcess() {
	while true; do
		if ! pgrep -f $1; then
			echo "Process $1 has completed." | mail -s "Process Complete" ${USER}.tech
			break
		fi
		sleep 60
	done
}

function websiteStatus() {
	curl -s --head --request GET $1 | grep "200 OK"
}

function fzf-eval() {
	echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}

eval $(thefuck --alias)

function obm() {
	URL=$(cat ~/.config/google-chrome/Default/Bookmarks | jq -r '.roots[] | recurse(.children?[]?) | select(.url!=null) | "\(.name) (\(.url?))"' | fzf | head -1 | sed -n 's/[^(]*(\(http[^)]*\).*/\1/p')
	google-chrome $URL &
}

function fkill() {
	ps aux | fzf | awk '{ print $2 }' | xargs kill -9
}
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

function k8exec() {
	kubectl exec -it $1 -- /bin/sh
}

function testpost() {
	nc -zv $1 $2
}
