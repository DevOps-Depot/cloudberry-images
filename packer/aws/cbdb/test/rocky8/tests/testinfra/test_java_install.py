import testinfra

def test_profile_d_updated(host):
    # Verify PATH update in /etc/profile.d/java.sh
    profile_d = host.file("/etc/profile.d/java.sh")
    assert profile_d.exists, "/etc/profile.d/java.sh does not exist"
    assert profile_d.is_file, "/etc/profile.d/java.sh is not a file"
