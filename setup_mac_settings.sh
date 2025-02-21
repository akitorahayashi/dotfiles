#!/bin/bash

echo "Mac のシステム設定を適用中..."
defaults write -g com.apple.trackpad.scaling -float 1.5
defaults write -g com.apple.mouse.scaling -float 
defaults write -g InitialKeyRepeat -int 
defaults write -g KeyRepeat -int 
defaults write com.apple.dock tilesize -int 50
defaults write com.apple.dock autohide -bool 
defaults write com.apple.dock show-recents -bool 
killall Dock
defaults write com.apple.finder ShowPathbar -bool 
defaults write com.apple.finder ShowStatusBar -bool 
defaults write com.apple.finder AppleShowAllFiles -bool 
killall Finder
defaults write NSGlobalDomain _HIHideMenuBar -bool 
mkdir -p 
defaults write com.apple.screencapture location ""
killall SystemUIServer
echo "Mac のシステム設定が適用されました ✅"
