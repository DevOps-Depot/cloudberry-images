#!/bin/bash

# Enable strict mode for better error handling
set -euo pipefail

# Header indicating the script execution
echo "Executing system_add_cbdb_test_rpm_dependencies.sh..."

# Update the package cache
sudo dnf makecache

# Install EPEL repository and import GPG keys for EPEL and Rocky Linux
sudo dnf install -y epel-release
sudo rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8
sudo rpm --import https://dl.rockylinux.org/pub/sig/8/cloud/x86_64/cloud-kernel/RPM-GPG-KEY-Rocky-SIG-Cloud

# Update the package cache again to include the new repository
sudo dnf makecache

# Disable EPEL repositories to avoid conflicts
sudo dnf config-manager --disable epel

# Install basic utilities
sudo dnf install -y git vim tmux wget

# Install additional tools from EPEL repository
sudo dnf install -y --enablerepo=epel the_silver_searcher htop

# Install Runtime tools
sudo dnf install -y \
     java-11-openjdk

# Footer indicating the script execution is complete
echo "system_add_cbdb_test_rpm_dependencies.sh execution completed."
