# ----------------------------------------------------------------------
# Dockerfile for Cloudberry Database Base Environment
# ----------------------------------------------------------------------
# This Dockerfile sets up a Rocky Linux 8-based container to serve as
# a base environment for evaluating the Cloudberry Database. It installs
# necessary system utilities, configures the environment for SSH access,
# and sets up a 'gpadmin' user with sudo privileges. The Cloudberry
# Database RPM can be installed into this container for testing and
# functional verification.
#
# Key Features:
# - Locale setup for en_US.UTF-8
# - SSH daemon setup for remote access
# - Essential system utilities installation
# - Separate user creation and configuration steps
#
# Security Considerations:
# - This Dockerfile prioritizes ease of use for functional testing and
#   evaluation. It includes configurations such as passwordless sudo access
#   for the 'gpadmin' user and SSH access with password authentication.
# - These configurations are suitable for testing and development but
#   should NOT be used in a production environment due to potential security
#   risks.
#
# Usage:
#   docker build -t cloudberry-db-base-env .
#   docker run -h cdw -it cloudberry-db-base-env
# ----------------------------------------------------------------------

# Base image: Rocky Linux 8
FROM rockylinux/rockylinux:8

# Argument for configuring the timezone
ARG TIMEZONE_VAR="America/Los_Angeles"

# Environment variables for locale
ENV LANG=en_US.UTF-8

# ----------------------------------------------------------------------
# System Update and Installation
# ----------------------------------------------------------------------
# Update the system and install essential system utilities required for
# running and testing Cloudberry Database. Cleanup the DNF cache afterward
# to reduce the image size.
# ----------------------------------------------------------------------
RUN dnf install -y \
        glibc-locale-source \
        openssh \
        openssh-clients \
        openssh-server \
        procps-ng \
        sudo \
        which \
        && \
    dnf clean all  # Clean up DNF cache after package installations

# ----------------------------------------------------------------------
# User Creation and Configuration
# ----------------------------------------------------------------------
# - Create the 'gpadmin' user and group.
# - Configure the 'gpadmin' user with passwordless sudo privileges.
# - Add Cloudberry-specific entries to the gpadmin's .bashrc.
# ----------------------------------------------------------------------
RUN /usr/sbin/groupadd gpadmin && \
    /usr/sbin/useradd gpadmin -g gpadmin -G wheel && \
    echo 'gpadmin ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/90-gpadmin && \
    echo -e '\n# Add Cloudberry entries\nif [ -f /usr/local/cbdb/greenplum_path.sh ]; then\n  source /usr/local/cbdb/greenplum_path.sh\n  export COORDINATOR_DATA_DIRECTORY=/data1/coordinator/gpseg-1\nfi' >> /home/gpadmin/.bashrc

# ----------------------------------------------------------------------
# Copy Configuration Files and Setup the Environment
# ----------------------------------------------------------------------
# - Copy custom configuration files from the build context to /tmp/.
# - Apply custom system limits and timezone.
# - Set up SSH for password-based authentication.
# - Generate locale and set the default locale to en_US.UTF-8.
# ----------------------------------------------------------------------
COPY ./configs/* /tmp/

RUN cp /tmp/90-cbdb-limits /etc/security/limits.d/90-cbdb-limits && \
    sed -i.bak -r 's/^(session\s+required\s+pam_limits.so)/#\1/' /etc/pam.d/* && \
    cat /usr/share/zoneinfo/${TIMEZONE_VAR} > /etc/localtime && \
    chmod 777 /tmp/init_system.sh && \
    setcap cap_net_raw+ep /usr/bin/ping && \
    ssh-keygen -A && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    echo "LANG=en_US.UTF-8" | tee /etc/locale.conf

RUN dnf install -y https://cloudberry-rpm-dev-bucket.s3.amazonaws.com/repo/el8/x86_64/cloudberry-dev-repo-1.0-1.el8.x86_64.rpm && \
    dnf install -y cloudberry-db

# ----------------------------------------------------------------------
# Set the Default User and Command
# ----------------------------------------------------------------------
# The default user is set to 'gpadmin', and the container starts by
# running the init_system.sh script. This container serves as a base
# environment, and the Cloudberry Database RPM can be installed for
# testing and functional verification.
# ----------------------------------------------------------------------
USER gpadmin

CMD ["bash","-c","/tmp/init_system.sh"]
