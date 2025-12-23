#!/bin/bash

# Spotlight Reindex Script
# Forces full reindex of the main volume.
# One-time operation – cannot be "undone", so no revert flag.

echo "Forcing Spotlight reindex on / (root volume)..."
sudo mdutil -E /

echo "Reindexing has started. This may take minutes to hours depending on drive size."
echo "Monitor progress via System Settings → Siri & Spotlight → Spotlight Privacy."
echo "Finder may be temporarily busier while indexing."
