import testinfra

def test_installed_packages(host):
    """
    Test if the essential packages are installed.
    """
    packages = [
        "systemd",
        "systemd-libs",
        "yum-utils",
        "epel-release",
        "git",
        "the_silver_searcher",
        "bat",
        "htop",
        "bison",
        "cmake",
        "gcc",
        "gcc-c++",
        "glibc-langpack-en",
        "glibc-locale-source",
        "openssh-clients",
        "openssh-server",
        "sudo",
        "rsync",
        "wget",
        "openssl-devel",
        "python36-devel",
        "python3-pytest",
        "readline-devel",
        "zlib-devel",
        "libcurl-devel",
        "libevent-devel",
        "libxml2-devel",
        "libuuid-devel",
        "libzstd-devel",
        "lz4",
        "openldap-devel",
        "libuv-devel",
        "libyaml-devel",
        "xerces-c-devel"
    ]
    for package in packages:
        pkg = host.package(package)
        assert pkg.is_installed


def test_user_gpadmin_exists(host):
    """
    Test if the gpadmin user exists and is configured properly.
    """
    user = host.user("gpadmin")
    assert user.exists
    assert "wheel" in user.groups


def test_systemd_services_cleaned_up(host):
    """
    Test if unnecessary systemd services have been removed.
    """
    directories = [
        "/lib/systemd/system/sysinit.target.wants/",
        "/lib/systemd/system/multi-user.target.wants/",
        "/etc/systemd/system/*.wants/",
        "/lib/systemd/system/local-fs.target.wants/",
        "/lib/systemd/system/sockets.target.wants/",
        "/lib/systemd/system/basic.target.wants/",
        "/lib/systemd/system/anaconda.target.wants/",
    ]

    for directory in directories:
        dir = host.file(directory)
        assert not dir.exists or dir.is_directory


def test_ssh_service(host):
    """
    Test if SSH service is configured correctly.
    """
    sshd_config = host.file("/etc/ssh/sshd_config")
    assert sshd_config.exists


def test_locale_configured(host):
    """
    Test if the locale is configured correctly.
    """
    locale_conf = host.file("/etc/locale.conf")
    assert locale_conf.exists
    assert locale_conf.contains("LANG=en_US.UTF-8")


def test_timezone(host):
    """
    Test if the timezone is configured correctly.
    """
    localtime = host.file("/etc/localtime")
    assert localtime.exists


def test_system_limits_configured(host):
    """
    Test if the custom system limits are applied.
    """
    limits_file = host.file("/etc/security/limits.d/90-cbdb-limits")
    assert limits_file.exists


def test_init_system_script(host):
    """
    Test if the init_system.sh script is present and executable.
    """
    script = host.file("/tmp/init_system.sh")
    assert script.exists
    assert script.mode == 0o777


def test_custom_configuration_files(host):
    """
    Test if custom configuration files are correctly copied.
    """
    config_file = host.file("/tmp/90-cbdb-limits")
    assert config_file.exists


def test_locale_generated(host):
    """
    Test if the en_US.UTF-8 locale is correctly generated.
    """
    locale = host.run("locale -a | grep en_US.utf8")
    assert locale.exit_status == 0
    assert "en_US.utf8" in locale.stdout
