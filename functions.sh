function csv_pretty() {
  if [ -z "$1"]; then echo "Usage: csv_pretty <file.csv>"
  else cat "$1" | column -s, -t | less -F -S -X -K
  fi
}

function recently_modified() {
  recent_file=$(ls -t | head -n1)
  echo "Most recently modified file is: $recent_file"
} 

function mem_hog() {
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
}
