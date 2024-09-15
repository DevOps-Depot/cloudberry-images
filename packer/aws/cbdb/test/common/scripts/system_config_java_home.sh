#!/bin/bash

# Note: Update the JAVA_HOME path if the Java version or directory changes

# Enable strict mode for better error handling
set -euo pipefail

# Header indicating the script execution
echo "Executing system_config_java_home.sh..."

# Set JAVA_HOME
JAVA_HOME=$(dirname $(dirname $(readlink -f $(command -v java))))

# Ensure JAVA_HOME is set and the bin directory is in the PATH for all users
echo "export JAVA_HOME=${JAVA_HOME}" | sudo tee /etc/profile.d/java.sh > /dev/null
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/java.sh > /dev/null

# Verify JAVA_HOME and java version
echo "JAVA_HOME is set to $JAVA_HOME"
java -version

# Footer indicating the script execution is complete
echo "system_config_java_home.sh execution completed."
