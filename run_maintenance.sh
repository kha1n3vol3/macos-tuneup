#!/bin/bash

# Legacy Maintenance Scripts Runner
# Executes daily/weekly/monthly system tasks.
# Mostly useful on Big Sur; minimal effect on Sonoma.

echo "Running daily, weekly, and monthly maintenance scripts..."
sudo periodic daily weekly monthly

echo "Maintenance complete."
