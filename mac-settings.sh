#!/usr/bin/env bash

set -e

echo "Running configuration"
osascript -e 'tell application "System Preferences" to quit'

# Always expand the save dialog
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Ask for password right after sleep
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Folders on top when sorting by name in Finder
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Enable select in QuickLook
defaults write com.apple.finder QlEnableTextSelection -bool true

# Restart things so settings apply
killall Finder
killall Dock
