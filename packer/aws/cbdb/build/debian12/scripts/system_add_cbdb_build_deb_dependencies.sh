#!/bin/bash

# Enable strict mode for better error handling
set -euo pipefail

# Header indicating the script execution
echo "Executing system_add_cbdb_build_dependencies.sh..."

# Update package lists and upgrade existing packages
sudo apt -o Dpkg::Progress-Fancy=0 update -qq

# Install software-properties-common to add repositories
sudo apt -o Dpkg::Progress-Fancy=0 install -y software-properties-common

# Update package lists again after adding new repository
sudo apt -o Dpkg::Progress-Fancy=0 -qq update

# Install initial packages
sudo apt -o Dpkg::Progress-Fancy=0 -qq install -y git less

# Install additional utilities
sudo apt -o Dpkg::Progress-Fancy=0 -qq install -y bat htop silversearcher-ag sudo tmux

# Install build essentials and development tools
sudo apt -o Dpkg::Progress-Fancy=0 -qq install -y bison curl flex g++ gcc make vim wget

# Install library dependencies
sudo apt -o Dpkg::Progress-Fancy=0 -qq install -y \
     iproute2 \
     iputils-ping \
     libapr1-dev \
     libbz2-dev \
     libcurl4-openssl-dev \
     libevent-dev \
     libipc-run-perl \
     libjansson-dev \
     libkrb5-dev \
     libldap2-dev \
     liblz4-dev \
     libpam0g-dev \
     libperl-dev \
     libreadline-dev \
     libssl-dev \
     libtest-harness-perl \
     libtest-simple-perl \
     libuv1-dev \
     libxerces-c-dev \
     libxml2-dev \
     libyaml-dev \
     libzstd-dev \
     pkg-config \
     python3-dev \
     rsync \
     zlib1g-dev

# Footer indicating the script execution is complete
echo "system_add_cbdb_build_dependencies.sh execution completed."
