# Packer variables
variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "private_key_file" {
  type    = string
  default = ""
}

variable "vm_type" {
  type    = string
  default = ""
}

variable "os_name" {
  type    = string
  default = ""
}

variable "default_username" {
  description = "Default username for logging in"
  type        = string
  default     = "rocky"
}

variable "custom_shell_commands" {
  description = "Additional commands to run on the EC2 instance, to customize the instance, like installing packages"
  type        = list(string)
  default     = []
}

# Define a variable for the runner version
variable "runner_version" {
  description = "The version (no v prefix) of the runner software to install. The latest release will be fetched from GitHub if not provided."
  type        = string
  default     = ""
}

# Fetch the latest GitHub runner release if no version is provided
data "http" "github_runner_release_json" {
  url = "https://api.github.com/repos/actions/runner/releases/latest"

  request_headers = {
    Accept = "application/vnd.github+json"
    X-GitHub-Api-Version = "2022-11-28"
  }
}

# Determine the runner version to use
locals {
  runner_version = coalesce(var.runner_version, trimprefix(jsondecode(data.http.github_runner_release_json.body).tag_name, "v"))
}

# Define the Amazon EBS source for building the AMI
source "amazon-ebs" "base-cbdb-build-image" {
  # AWS credentials
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.region

  # Instance type and spot price for cost efficiency
  instance_type = "t3.2xlarge"
  ## spot_price    = "0.0183"

  # Define the source AMI filter to find the latest Rocky 8 base AMI
  source_ami_filter {
    filters = {
      name                = "Rocky-8-EC2-Base*x86_64"
      virtualization-type = "hvm"
    }
    owners      = ["792107900819"]
    most_recent = true
  }

  # SSH configuration
  ssh_username         = "rocky"
  ssh_keypair_name     = var.key_name
  ssh_private_key_file = var.private_key_file

  # Name of the resulting AMI with current timestamp
  ami_name = format("packer-%s-%s-%s", var.vm_type, var.os_name, formatdate("YYYYMMDD-HHmmss", timestamp()))

  # Define block device mappings
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 12  # 12 GB volume size to meet snapshot requirements
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

# Build block to define the build steps
build {
  sources = ["source.amazon-ebs.base-cbdb-build-image"]

  # Provisioner to add CBDB build RPM dependencies
  provisioner "shell" {
    script = "scripts/system_add_cbdb_build_rpm_dependencies.sh"
  }

  # Provisioner to add CBDB Xerces-c build dependency
  provisioner "shell" {
    script = "../common/scripts/system_add_cbdb_xerces-c_build_dependency.sh"
  }

  # Provisioner to add kernel configurations
  provisioner "shell" {
    script = "../common/scripts/system_add_kernel_configs.sh"
  }

  # Provisioner to disable SELinux
  provisioner "shell" {
    script = "../common/scripts/system_disable_SELinux.sh"
  }

  # Provisioner to add the gpadmin user
  provisioner "shell" {
    script = "../common/scripts/system_adduser_gpadmin.sh"
  }

  # Provisioner to set ulimits for gpadmin
  provisioner "shell" {
    script = "../common/scripts/system_add_gpadmin_ulimits.sh"
  }

  # Provisioner to configure the gpadmin environment
  provisioner "shell" {
    script = "../common/scripts/gpadmin-configure-environment.sh"
  }

  # Provisioner to add the Golang
  provisioner "shell" {
    script = "../common/scripts/system_add_golang.sh"
  }

  # Provisioner to set JAVA_HOME
  provisioner "shell" {
    script = "../common/scripts/system_config_java_home.sh"
  }

  provisioner "shell" {
    environment_vars = []
    inline = concat([
      "sudo dnf makecache",
      "sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo dnf makecache",
      "sudo dnf install -y docker-ce docker-ce-cli containerd.io",
      "echo '{\"default-shm-size\": \"1G\"}' | sudo tee /etc/docker/daemon.json",
      "sudo systemctl start docker",
      "sudo systemctl status docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker $(whoami)",
      "sudo dnf install -y https://amazoncloudwatch-agent.s3.amazonaws.com/redhat/amd64/latest/amazon-cloudwatch-agent.rpm jq git",
      "sudo dnf install -y https://s3.${var.region}.amazonaws.com/amazon-ssm-${var.region}/latest/linux_amd64/amazon-ssm-agent.rpm",
      "sudo systemctl start amazon-ssm-agent",
      "sudo systemctl enable amazon-ssm-agent",
      "sudo dnf install -y unzip",
      "sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
      "sudo unzip -q awscliv2.zip",
      "sudo rm -f awscliv2.zip",
      "sudo ./aws/install",

    ], var.custom_shell_commands)
  }

  provisioner "file" {
    content = templatefile("/Users/eespino/workspace/DevOps-Depot/terraform-aws-github-runner/images/install-runner.sh", {
      install_runner = templatefile("/Users/eespino/workspace/DevOps-Depot/terraform-aws-github-runner/modules/runners/templates/install-runner.sh", {
        ARM_PATCH                       = ""
        S3_LOCATION_RUNNER_DISTRIBUTION = ""
        RUNNER_ARCHITECTURE             = "x64"
      })
    })
    destination = "/tmp/install-runner.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo chmod +x /tmp/install-runner.sh",
      "echo ${var.default_username} > /tmp/install-user.txt",
      "sudo RUNNER_ARCHITECTURE=x64 RUNNER_TARBALL_URL=https://github.com/actions/runner/releases/download/v${local.runner_version}/actions-runner-linux-x64-${local.runner_version}.tar.gz /tmp/install-runner.sh"
    ]
  }

  provisioner "file" {
    content = templatefile("/Users/eespino/workspace/DevOps-Depot/terraform-aws-github-runner/images/start-runner.sh", {
      start_runner = templatefile("/Users/eespino/workspace/DevOps-Depot/terraform-aws-github-runner/modules/runners/templates/start-runner.sh", { metadata_tags = "enabled" })
    })
    destination = "/tmp/start-runner.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/start-runner.sh /var/lib/cloud/scripts/per-boot/start-runner.sh",
      "sudo chmod +x /var/lib/cloud/scripts/per-boot/start-runner.sh",
    ]
  }

  # Post-processor to generate a manifest file
  post-processors {
    post-processor "manifest" {
      output = "packer-manifest.json"
    }
  }
}
