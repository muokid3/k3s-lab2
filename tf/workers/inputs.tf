variable "zone" {
  description = "route 53 zone"
}

variable "bastion_sg_id" {
  description = "bastion sg"
}

variable "control_plane_sg_id" {
  description = "control plane sg"
}

variable "vpc" {
  description = "the vpc to connect to"
}

variable "az" {
  description = "availability zones"
}

variable "private_key_path" {
  description = "path to private key to inject into the instances to allow ssh"
  default     = "./ssh/id_rsa"
}

variable "public_key_path" {
  description = "path to public key to inject into the instances to allow ssh"
  default     = "./ssh/id_rsa.pub"
}

variable "key_name" {
  description = "master key for the lab"
  default     = "lab-key"
}

variable "name" {
  description = "A name to be applied to make everything unique and personal"
}

variable "aws_region" {
  description = "Europe"
  default     = "eu-west-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "owner" {
  description = "owner of the resource"
}

variable "project" {
  description = "project name"
}

variable "env" {
  description = "environment - i.e. dev, test, prod"
}

variable "workspace" {
  description = "terraform workspace"
  default     = "default"
}
