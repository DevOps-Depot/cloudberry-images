#!/bin/bash

# Enable strict mode
set -euo pipefail

# Update the dynamic linker configuration
echo "Updating dynamic linker configuration..."
sudo sh -c 'echo "/usr/local/xerces-c/lib" > /etc/ld.so.conf.d/xerces-c.conf'
sudo ldconfig

# Update the PKG_CONFIG_PATH
echo "Updating PKG_CONFIG_PATH..."
sudo sh -c 'echo "export PKG_CONFIG_PATH=\"/usr/local/xerces-c/lib/pkgconfig:\${PKG_CONFIG_PATH:-}\"" > /etc/profile.d/xerces-c.sh'

# Make the changes take effect immediately
source /etc/profile.d/xerces-c.sh

# Verify the changes
echo "Verifying changes..."
if ldconfig -p | grep -q libxerces-c-3.2.so; then
    echo "Dynamic linker configuration updated successfully."
else
    echo "Error: Dynamic linker configuration update failed."
    exit 1
fi

if pkg-config --cflags --libs xerces-c; then
    echo "pkg-config configuration updated successfully."
else
    echo "Error: pkg-config configuration update failed."
    exit 1
fi

echo "Xerces-C installation fixes completed successfully."
