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
