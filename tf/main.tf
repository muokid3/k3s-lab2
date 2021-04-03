
provider "aws" {
  profile = "labs"
  region  = var.region
}

module "vpc" {
  source    = "./vpc"
  name      = var.name
  owner     = var.owner
  project   = var.project
  env       = var.env
  workspace = var.workspace
}

module "bastion" {
  source = "./bastion"
  vpc    = module.vpc.vpc
  az     = module.vpc.az

  name             = var.name
  owner            = var.owner
  project          = var.project
  env              = var.env
  workspace        = var.workspace
  key_name         = var.key_name
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  instance_type    = var.bastion_type
  aws_region       = var.region
}

module "control_plane" {
  source        = "./control-plane"
  vpc           = module.vpc.vpc
  az            = module.vpc.az
  zone          = module.vpc.zone
  bastion_sg_id = module.bastion.bastion_sg_id
  workers_sg_id = module.workers.workers_sg_id

  name             = var.name
  owner            = var.owner
  project          = var.project
  env              = var.env
  workspace        = var.workspace
  key_name         = var.key_name
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  instance_type    = var.server_type
  aws_region       = var.region
}

module "workers" {
  source              = "./workers"
  depends_on          = [module.vpc.dns_record]
  vpc                 = module.vpc.vpc
  az                  = module.vpc.az
  zone                = module.vpc.zone
  bastion_sg_id       = module.bastion.bastion_sg_id
  control_plane_sg_id = module.control_plane.control_plane_sg_id

  name             = var.name
  owner            = var.owner
  project          = var.project
  env              = var.env
  workspace        = var.workspace
  key_name         = var.key_name
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  instance_type    = var.worker_type
  aws_region       = var.region
}
