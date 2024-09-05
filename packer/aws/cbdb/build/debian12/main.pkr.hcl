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
  default     = "admin"
}

variable "custom_shell_commands" {
  description = "Additional commands to run on the EC2 instance, to customize the instance, like installing packages"
  type        = list(string)
  default     = []
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

  # Define the source AMI filter to find the latest Debian 12 base AMI
  source_ami_filter {
    filters = {
      name                = "debian-12-amd64-*"
      virtualization-type = "hvm"
    }
    owners      = ["136693071363"]
    most_recent = true
  }

  # SSH configuration
  ssh_username         = "admin"
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

  # Provisioner to add CBDB build DEB dependencies
  provisioner "shell" {
    script = "scripts/system_add_cbdb_build_deb_dependencies.sh"
  }

  # Provisioner to add kernel configurations
  provisioner "shell" {
    script = "../common/scripts/system_add_kernel_configs.sh"
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

  # Provisioner to add Docker DEB dependencies
  provisioner "shell" {
    script = "scripts/system_docker_setup.sh"
  }

  # Provisioner to Set default locale
  provisioner "shell" {
    script = "scripts/system_set_default_locale.sh"
  }

  # Post-processor to generate a manifest file
  post-processors {
    post-processor "manifest" {
      output = "packer-manifest.json"
    }
  }
}
