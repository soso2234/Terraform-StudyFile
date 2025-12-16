terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source         = "./modules/vpc"
  region         = "ap-northeast-2"
  pjt_name       = "tf"
  vpc_cidr_block = "10.0.0.0/16"
}

module "subnet" {
  source        = "./modules/subnet"
  region        = "ap-northeast-2"
  vpc_id        = module.vpc.vpc_id
  sn_cidr_block = "10.0.0.0/24"
  az_name       = "ap-northeast-2a"
}

module "route_table" {
  source   = "./modules/route_table"
  region   = "ap-northeast-2"
  vpc_id   = module.vpc.vpc_id
  igw_id   = module.vpc.igw_id
  pjt_name = "tf"
  sn_id    = module.subnet.sn_id
}

module "sg" {
  source = "./modules/security_group"
  region = "ap-northeast-2"
  vpc_id = module.vpc.vpc_id
  pjt_name = "tf"
}