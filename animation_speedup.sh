#!/bin/bash

# macOS Animation Speedup Script – Interactive Version
# Reduces animation delays for a snappier feel.
# - No flag: Detects current state and prompts for apply or revert.
# - --apply: Force apply optimizations.
# - --revert: Force revert to defaults.
# Compatible with Big Sur and Sonoma.

set -e

# Helper functions to check current settings
key_exists() {
    defaults read com.apple.dock "$1" >/dev/null 2>&1
}

key_has_value() {
    local current=$(defaults read com.apple.dock "$1" 2>/dev/null || echo "")
    [[ "$current" == "$2" ]]
}

# Detect if optimizations are currently applied
detect_state() {
    local applied=true

    if ! key_exists autohide-delay || ! key_has_value autohide-delay "0" ; then
        applied=false
    fi
    if ! key_exists autohide-time-modifier || ! key_has_value autohide-time-modifier "0.5" ; then
        applied=false
    fi
    if ! key_exists expose-animation-duration || ! key_has_value expose-animation-duration "0.1" ; then
        applied=false
    fi
    if ! key_exists launchanim || ! key_has_value launchanim "0" ; then  # false = 0
        applied=false
    fi

    echo "$applied"
}

CURRENT_STATE=$(detect_state)
if [[ "$CURRENT_STATE" == true ]]; then
    CURRENT_TEXT="currently APPLIED"
    SUGGESTED="revert"
else
    CURRENT_TEXT="currently NOT applied"
    SUGGESTED="apply"
fi

# Parse explicit flags
if [[ "$1" == "--apply" ]]; then
    ACTION="apply"
elif [[ "$1" == "--revert" ]]; then
    ACTION="revert"
elif [[ -n "$1" ]]; then
    echo "Usage: $0 [--apply | --revert]"
    echo "   No flag: Interactive prompt to apply or revert"
    exit 1
else
    ACTION=""  # Will prompt
fi

# Interactive prompt if no flag given
if [[ -z "$ACTION" ]]; then
    echo "Animation optimizations are $CURRENT_TEXT."
    echo
    echo "What would you like to do?"
    echo "  [a] Apply faster animations"
    echo "  [r] Revert to macOS default animations"
    echo "  [q] Quit without changes"
    echo -n "Enter choice (a/r/q) [default: $SUGGESTED]: "

    read -r choice
    choice=${choice:-$SUGGESTED}  # Default to suggested if just Enter pressed

    case "$choice" in
        a|A|[aA]pply|[aA]pple) ACTION="apply" ;;
        r|R|[rR]evert|[rR]ev)  ACTION="revert" ;;
        q|Q|[qQ]uit)           echo "No changes made."; exit 0 ;;
        *)                     echo "Invalid choice – quitting."; exit 1 ;;
    esac
fi

echo
echo "Performing: $( [[ "$ACTION" == "apply" ]] && echo "Apply faster animations" || echo "Revert to defaults" )"

if [[ "$ACTION" == "apply" ]]; then
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    defaults write com.apple.dock expose-animation-duration -float 0.1
    defaults write com.apple.dock launchanim -bool false
else
    defaults delete com.apple.dock autohide-delay 2>/dev/null || true
    defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true
    defaults delete com.apple.dock expose-animation-duration 2>/dev/null || true
    defaults delete com.apple.dock launchanim 2>/dev/null || true
fi

echo "Restarting Dock to apply changes..."
killall Dock || true

echo
echo "Done! Changes are now active."
echo "Run the script again to change or revert."
