#!/bin/bash

# Enable strict mode for better error handling
set -euo pipefail

# Header indicating the script execution
echo "Executing system_add_cbdb_xerces-c_build_dependency.sh..."

# Change to home directory
cd ~

# Variables
XERCES_LATEST_RELEASE=3.2.5
INSTALL_PREFIX="/usr/local/xerces-c"

# Download and verify the tarball
wget -nv "https://dlcdn.apache.org//xerces/c/3/sources/xerces-c-${XERCES_LATEST_RELEASE}.tar.gz"
echo "$(curl -sL https://dlcdn.apache.org//xerces/c/3/sources/xerces-c-${XERCES_LATEST_RELEASE}.tar.gz.sha256)" | sha256sum -c -

# Extract, configure, build, and install
tar xf "xerces-c-${XERCES_LATEST_RELEASE}.tar.gz"
rm "xerces-c-${XERCES_LATEST_RELEASE}.tar.gz"
cd xerces-c-${XERCES_LATEST_RELEASE}
sudo ln -s "${INSTALL_PREFIX}-${XERCES_LATEST_RELEASE}" "${INSTALL_PREFIX}"

./configure --prefix="${INSTALL_PREFIX}-${XERCES_LATEST_RELEASE}"
make -j$(nproc)
make check
sudo make install -C ~/xerces-c-${XERCES_LATEST_RELEASE}

# Cleanup
rm -rf ~/xerces-c*

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

# Footer indicating the script execution is complete
echo "system_add_cbdb_xerces-c_build_dependency.sh execution completed."
