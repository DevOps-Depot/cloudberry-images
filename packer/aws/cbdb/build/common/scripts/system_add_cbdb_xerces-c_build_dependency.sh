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
echo "$(curl -sL https://dlcdn.apache.org//xerces/c/3/sources/xerces-c-3.2.5.tar.gz.sha256)" | sha256sum -c -

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

# Footer indicating the script execution is complete
echo "system_add_cbdb_xerces-c_build_dependency.sh execution completed."
