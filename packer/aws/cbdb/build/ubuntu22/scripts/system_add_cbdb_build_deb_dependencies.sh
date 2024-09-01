#!/bin/bash

# Enable strict mode for better error handling
set -euo pipefail

# Header indicating the script execution
echo "Executing system_add_cbdb_build_dependencies.sh..."

# Update package lists and upgrade existing packages
sudo apt-get update
sudo apt-get upgrade -y

# Install software-properties-common to add repositories
sudo apt-get install -y software-properties-common

# Add universe repository
sudo add-apt-repository universe

# Update package lists again after adding new repository
sudo apt-get update

# Install initial packages
sudo apt-get install -y git less

# Install additional utilities
sudo apt-get install -y bat htop silversearcher-ag sudo tmux

# Install build essentials and development tools
sudo apt-get install -y bison curl flex g++-11 gcc-11 make vim wget

# Install library dependencies
sudo apt-get install -y \
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

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100
sudo update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc x86_64-linux-gnu-gcc /usr/bin/gcc-11 200

# Footer indicating the script execution is complete
echo "system_add_cbdb_build_dependencies.sh execution completed."
