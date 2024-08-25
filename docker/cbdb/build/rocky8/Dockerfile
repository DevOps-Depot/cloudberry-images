# ----------------------------------------------------------------------
# Dockerfile for Cloudberry Database Build Environment
# ----------------------------------------------------------------------
# This Dockerfile sets up a Rocky Linux 9-based container for building
# and developing the Cloudberry Database. It installs necessary system
# utilities, development tools, and configures the environment for SSH
# access and systemd support.
#
# Key Features:
# - Locale setup for en_US.UTF-8
# - SSH daemon setup for remote access
# - Essential development tools and libraries installation
# - User configuration for 'gpadmin' with sudo privileges
#
# Usage:
#   docker build -t cloudberry-db-env .
#   docker run -h cdw -it cloudberry-db-env
# ----------------------------------------------------------------------

# Base image: Rocky Linux 8
FROM rockylinux/rockylinux:8

# Argument for configuring the timezone
ARG TIMEZONE_VAR="America/Los_Angeles"

# Environment variables for locale and user
ENV container=docker
ENV LANG=en_US.UTF-8
ENV USER=gpadmin

# ----------------------------------------------------------------------
# Install Development Tools and Utilities
# ----------------------------------------------------------------------
# Install various development tools, system utilities, and libraries
# required for building and running Cloudberry Database.
# - EPEL repository is enabled for additional packages.
# - Cleanup steps are added to reduce image size after installation.
# ----------------------------------------------------------------------
RUN dnf makecache && \
    dnf install -y \
        epel-release \
        git && \
    dnf makecache && \
    dnf config-manager --disable epel && \
    dnf install -y -d0 --enablerepo=epel \
        the_silver_searcher \
        htop && \
    dnf install -y -d0 \
        apr-devel \
        autoconf \
        bison \
        bzip2-devel \
        diffutils \
        flex \
        gcc \
        gcc-c++ \
        glibc-langpack-en \
        glibc-locale-source \
        iproute \
        krb5-devel \
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
        perl-Env \
        perl-ExtUtils-Embed \
        perl-Test-Simple \
        procps-ng \
        python3 \
        python3-devel \
        readline-devel \
        rsync \
        sshpass \
        sudo \
        tar \
        unzip \
        util-linux-ng \
        wget \
        which \
        zlib-devel && \
    dnf install -y -d0 --enablerepo=devel \
        libuv-devel \
        libyaml-devel \
        perl-IPC-Run && \
    dnf clean all && \
    cd && XERCES_LATEST_RELEASE=3.2.5 && \
    wget -nv "https://dlcdn.apache.org//xerces/c/3/sources/xerces-c-${XERCES_LATEST_RELEASE}.tar.gz" && \
    echo "$(curl -sL https://dlcdn.apache.org//xerces/c/3/sources/xerces-c-3.2.5.tar.gz.sha256)" | sha256sum -c - && \
    tar xf "xerces-c-${XERCES_LATEST_RELEASE}.tar.gz"; rm "xerces-c-${XERCES_LATEST_RELEASE}.tar.gz" && \
    cd xerces-c-${XERCES_LATEST_RELEASE} && \
    ./configure --prefix=/usr/local/xerces-c && \
    make -j$(nproc) && \
    make check && \
    make install -C ~/xerces-c-${XERCES_LATEST_RELEASE} && \
    rm -rf ~/xerces-c*

# ----------------------------------------------------------------------
# Copy Configuration Files and Setup the Environment
# ----------------------------------------------------------------------
# - Copy custom configuration files from the build context to /tmp/.
# - Apply custom system limits and timezone.
# - Create and configure the 'gpadmin' user with sudo privileges.
# - Set up SSH for password-based authentication.
# - Generate locale and set the default locale to en_US.UTF-8.
# ----------------------------------------------------------------------
COPY ./configs/* /tmp/

RUN cp /tmp/90-cbdb-limits /etc/security/limits.d/90-cbdb-limits && \
    sed -i.bak -r 's/^(session\s+required\s+pam_limits.so)/#\1/' /etc/pam.d/* && \
    cat /usr/share/zoneinfo/${TIMEZONE_VAR} > /etc/localtime && \
    chmod 777 /tmp/init_system.sh && \
    /usr/sbin/groupadd gpadmin && \
    /usr/sbin/useradd gpadmin -g gpadmin -G wheel && \
    setcap cap_net_raw+ep /usr/bin/ping && \
    echo 'gpadmin ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/90-gpadmin && \
    echo -e '\n# Add Cloudberry entries\nif [ -f /usr/local/cbdb/greenplum_path.sh ]; then\n  source /usr/local/cbdb/greenplum_path.sh\nfi' >> /home/gpadmin/.bashrc && \
    ssh-keygen -A && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    echo "LANG=en_US.UTF-8" | tee /etc/locale.conf && \
    dnf clean all  # Final cleanup to remove unnecessary files

# Install testinfra via pip
RUN pip3 install pytest-testinfra

# Example: Copying test files into the container
COPY tests /tests

# ----------------------------------------------------------------------
# Set the Default User and Command
# ----------------------------------------------------------------------
# The default user is set to 'gpadmin', and the container starts by
# running the init_system.sh script. The container also mounts the
# /sys/fs/cgroup volume for systemd compatibility.
# ----------------------------------------------------------------------
USER gpadmin

VOLUME [ "/sys/fs/cgroup" ]
CMD ["bash","-c","/tmp/init_system.sh"]
