#!/bin/bash

# system_set_default_locale.sh
# This script sets the system-wide locale to en_US.UTF-8 on a Debian-based system.

# Enable strict mode for better error handling
# -e: Exit immediately if a command exits with a non-zero status
# -u: Treat unset variables as an error when substituting
# -o pipefail: Return value of a pipeline is the status of the last command to exit with a non-zero status
set -euo pipefail

# Header indicating the script execution
echo "Executing system_set_default_locale.sh..."

# Update package lists to ensure we have the latest information
sudo apt-get update

# Uncomment the en_US.UTF-8 locale in /etc/locale.gen
# This allows the locale to be generated
sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

# Generate the en_US.UTF-8 locale
sudo locale-gen en_US.UTF-8

# Display current locale settings for reference
echo "Current locale settings:"
locale

# Generate en_US.UTF-8 locale again to ensure it's available
# This step might be redundant but ensures the locale is definitely generated
sudo locale-gen en_US.UTF-8

# Display current /etc/default/locale content for reference
echo "Current /etc/default/locale content:"
cat /etc/default/locale

# Set system-wide locale to en_US.UTF-8
# This updates /etc/default/locale
sudo update-locale LANG=en_US.UTF-8

# Display updated /etc/default/locale content to confirm changes
echo "Updated /etc/default/locale content:"
cat /etc/default/locale

# Footer indicating the script execution is complete
echo "system_set_default_locale.sh execution completed."

# Note: After running this script, you may need to log out and log back in
# or restart your system for the changes to take full effect.
