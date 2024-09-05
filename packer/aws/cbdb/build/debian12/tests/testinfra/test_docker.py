import pytest

def test_docker_installed(host):
    docker = host.package("docker-ce")
    assert docker.is_installed
    assert docker.version.startswith("5")  # Adjust version as needed

def test_docker_command(host):
    command = host.run("docker --version")
    assert command.rc == 0
    assert "Docker version" in command.stdout

def test_docker_hello_world(host):
    command = host.run("docker run hello-world")
    assert command.rc == 0
    assert "Hello from Docker!" in command.stdout

def test_user_in_docker_group(host):
    user = host.user().name
    assert 'docker' in host.user(user).groups

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
