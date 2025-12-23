#!/bin/bash

# macOS Memory Purge Script
# Forces clearing of inactive memory and disk caches.
# Temporary boost – no persistent changes, so no revert needed.

echo "Purging inactive memory and caches..."
sudo purge

echo "Done! Check Activity Monitor → Memory for immediate effect."
echo "Effects are temporary – macOS rebuilds caches as needed."
