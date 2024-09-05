#!/bin/bash

# install_docker.sh
# This script installs Docker on a Debian-based system.

# Enable strict mode for better error handling
# -e: Exit immediately if a command exits with a non-zero status
# -u: Treat unset variables as an error when substituting
# -o pipefail: Return value of a pipeline is the status of the last command to exit with a non-zero status
set -euo pipefail

# Header indicating the script execution
echo "Executing install_docker.sh..."

# Update the apt package index
echo "Updating package index..."
sudo apt-get update

# Install packages to allow apt to use a repository over HTTPS
echo "Installing prerequisites..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the Docker repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index again
echo "Updating package index with Docker repository..."
sudo apt-get update

# Install Docker Engine, containerd, and Docker Compose
echo "Installing Docker Engine, containerd, and Docker Compose..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user & gpadmin to docker group
echo "Adding current user and gpadmin to docker group..."
sudo usermod -aG docker $USER
sudo usermod -aG docker gpadmin

# Footer indicating the script execution is complete
echo "install_docker.sh execution completed."

echo "Please log out and log back in for the group changes to take effect."

# Note: After running this script, you need to log out and log back in
# for the group changes to take effect, allowing you to run Docker without sudo.
