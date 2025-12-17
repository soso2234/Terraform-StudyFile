module "vpc" {
  source         = "./modules/vpc"
  region         = var.region
  vpc_cidr_block = local.vpc_cidr_block[var.region]
  pjt_name       = var.pjt_name
  creat_igw      = true
}

module "subnet" {
  source   = "./modules/subnet"
  region   = var.region
  vpc_id   = module.vpc.vpc_id
  pjt_name = var.pjt_name
}

module "route_table" {
  source   = "./modules/route_table"
  region   = var.region
  vpc_id   = module.vpc.vpc_id
  igw_id   = module.vpc.igw_id
  pjt_name = var.pjt_name
  sn_id    = module.subnet.sn_id
}

module "security_group" {
  source   = "./modules/security_group"
  region   = var.region
  vpc_id   = module.vpc.vpc_id
  pjt_name = var.pjt_name
}

module "instance" {
  source        = "./modules/instance"
  ami           = var.ami
  instance_type = var.instance_type
  sn_id         = module.subnet.sn_id
  sg_ids        = [module.security_group.sg_id]
  pjt_name      = var.pjt_name
  vpc_id        = module.vpc.vpc_id
}

module "load_balancer" {
  source       = "./modules/load_balancer"
  region       = var.region
  vpc_id       = module.vpc.vpc_id
  instance_id1 = module.instance.instance_id1
  instance_id2 = module.instance.instance_id2
  sg_id        = [module.security_group.sg_id]
  sn_id        = module.subnet.sn_id
  pjt_name     = var.pjt_name
}