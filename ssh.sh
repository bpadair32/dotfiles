#!/usr/bin/env bash

echo "Creating SSH key"

ssh-keygen -t ed25519  -f ~/.ssh/id_ed25519

eval "$(ssh-agent -s)"

touch ~/.ssh/config
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config

ssh-add -K ~/.ssh/id_ed25519

pbcopy < ~/.ssh/id_ed25519.pub

echo "Copied new SSH key to clipboard."
