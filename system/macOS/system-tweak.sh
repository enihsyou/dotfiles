#!/usr/bin/env bash

# Disable delay, sets the Dock to hide immediately without delay
defaults write com.apple.dock autohide-delay -float 0; killall Dock
