#!/bin/bash

# Enable strict mode for better error handling
set -euo pipefail

# Header indicating the script execution
echo "Executing system_add_cbdb_build_rpm_dependencies.sh..."

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

# Install development tools and dependencies
sudo dnf install -y \
     apr-devel \
     autoconf \
     bison \
     bzip2-devel \
     cmake3 \
     createrepo_c \
     ed \
     flex \
     gcc \
     gcc-c++ \
     glibc-langpack-en \
     glibc-locale-source \
     initscripts \
     iproute \
     java-11-openjdk \
     java-11-openjdk-devel \
     krb5-devel \
     less \
     libcurl-devel \
     libevent-devel \
     libuuid-devel \
     libxml2-devel \
     libzstd-devel \
     lz4 \
     lz4-devel \
     make \
     m4 \
     nc \
     net-tools \
     openldap-devel \
     openssh-clients \
     openssh-server \
     openssl-devel \
     pam-devel \
     passwd \
     perl \
     perl-Env \
     perl-ExtUtils-Embed \
     perl-Test-Simple \
     pinentry \
     procps-ng \
     python3 \
     python3-devel \
     readline-devel \
     rpm-build \
     rpm-sign \
     rpmdevtools \
     rsync \
     sshpass \
     sudo \
     tar \
     unzip \
     util-linux-ng \
     wget \
     which \
     zlib-devel

# Install development tools and dependencies from Devel repository
sudo dnf install -y --enablerepo=devel \
     libuv-devel \
     libyaml-devel \
     perl-IPC-Run

# Footer indicating the script execution is complete
echo "system_add_cbdb_build_rpm_dependencies.sh execution completed."
