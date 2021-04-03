variable "name" {
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "packer_builder" {
  ami_name      = format("%s-k3s-server-%s", var.name, local.timestamp)
  instance_type = "t3.large"
  region        = "eu-west-2"

  run_tags = {
    owner = "self"
    type  = "k3s-server-packer-builder"
  }

  run_volume_tags = {
    owner = "self"
    type  = "k3s-server-packer-volume"
  }

  source_ami   = "ami-096cb92bb3580c759"
  ssh_username = "ubuntu"
}

build {
  name    = "k3s-server-ami-builder"
  sources = ["source.amazon-ebs.packer_builder"]

  provisioner "file" {
    destination = "/home/ubuntu/"
    source      = "./prep.sh"
  }

  provisioner "file" {
    destination = "/home/ubuntu/"
    source      = "./nginx-ingress-deploy.yaml"
  }

  provisioner "file" {
    destination = "/home/ubuntu/"
    source      = "./provision.sh"
  }

  provisioner "shell" {
    script = "./provision.sh"
  }
}
