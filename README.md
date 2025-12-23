# macOS Tune-Up Scripts – with Apply/Revert Support

This collection includes proper command-line flag support for **reversible** scripts:

- `--apply` : Apply the optimizations (default behavior if no flag is given).  
- `--revert` : Undo the changes and restore macOS defaults.

The **purge_memory.sh** and **rebuild_spotlight.sh** scripts are **not reversible** in the same way (they perform one-time actions), so they remain simple without flags.  
The **run_maintenance.sh** script is also left unchanged (it only runs built-in tasks).

**Usage Example:**
```bash
sudo ./animation_speedup.sh --apply    # Apply changes (same as running without flag)
sudo ./animation_speedup.sh --revert   # Restore defaults
```

**General Instructions:**
1. Save each script below as a `.sh` file.
2. Make executable: `chmod +x scriptname.sh`
3. Run with `sudo` (required for most operations).
4. Always back up your Mac first.

---

### 1. animation_speedup.sh

```bash
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
```

---

### 2. purge_memory.sh  *(no revert – one-time action)*

```bash
#!/bin/bash

# macOS Memory Purge Script
# Forces clearing of inactive memory and disk caches.
# Temporary boost – no persistent changes, so no revert needed.

echo "Purging inactive memory and caches..."
sudo purge

echo "Done! Check Activity Monitor → Memory for immediate effect."
echo "Effects are temporary – macOS rebuilds caches as needed."
```

---

### 3. rebuild_spotlight.sh  *(no revert – one-time reindex)*

```bash
#!/bin/bash

# Spotlight Reindex Script
# Forces full reindex of the main volume.
# One-time operation – cannot be "undone", so no revert flag.

echo "Forcing Spotlight reindex on / (root volume)..."
sudo mdutil -E /

echo "Reindexing has started. This may take minutes to hours depending on drive size."
echo "Monitor progress via System Settings → Siri & Spotlight → Spotlight Privacy."
echo "Finder may be temporarily busier while indexing."
```

---

### 4. run_maintenance.sh  *(legacy – no revert needed)*

```bash
#!/bin/bash

# Legacy Maintenance Scripts Runner
# Executes daily/weekly/monthly system tasks.
# Mostly useful on Big Sur; minimal effect on Sonoma.

echo "Running daily, weekly, and monthly maintenance scripts..."
sudo periodic daily weekly monthly

echo "Maintenance complete."
```

These updated scripts give you clean control over the only truly reversible tweak (animation reductions). The others perform safe, non-persistent actions. Enjoy the slightly snappier macOS!
