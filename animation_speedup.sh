#!/bin/bash

# macOS Animation Speedup Script
# Reduces animation delays and durations for a snappier interface feel.
# Supports --apply (default) and --revert flags.
# Compatible with Big Sur and Sonoma.

set -e  # Exit on error

ACTION="apply"
if [[ "$1" == "--revert" ]]; then
    ACTION="revert"
elif [[ "$1" == "--apply" ]]; then
    ACTION="apply"
elif [[ -n "$1" ]]; then
    echo "Usage: $0 [--apply | --revert]"
    exit 1
fi

echo "Animation speedup: $ACTION mode"

if [[ "$ACTION" == "apply" ]]; then
    echo "Applying faster Dock autohide..."
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5

    echo "Shortening Mission Control animation..."
    defaults write com.apple.dock expose-animation-duration -float 0.1

    echo "Disabling app launch bounce..."
    defaults write com.apple.dock launchanim -bool false
else
    echo "Reverting Dock autohide settings..."
    defaults delete com.apple.dock autohide-delay
    defaults delete com.apple.dock autohide-time-modifier

    echo "Reverting Mission Control animation..."
    defaults delete com.apple.dock expose-animation-duration

    echo "Re-enabling app launch bounce..."
    defaults delete com.apple.dock launchanim
fi

echo "Restarting Dock to apply changes..."
killall Dock || true  # Ignore if Dock not running

echo "Done! Full effect after restart or Dock restart."
