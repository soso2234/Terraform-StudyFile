terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }
}

provider "aws" {
  region = var.region_name
}

variable "region_name" {

}

variable "vpc_cidr_block" {

}

variable "pjt_name" {

}

variable "subnets" {

}

variable "sn_cidr_blocks" {

}

# vpc 생성 리소스
resource "aws_vpc" "tf_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.pjt_name}-vpc"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.pjt_name}-igw"
  }
}

resource "aws_subnet" "tf_sn" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = each.key
  availability_zone = each.value

  tags = {
    Name = "${var.pjt_name}-${each.key}-sn"
  }
}

resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "${var.pjt_name}-rt"
  }
}

resource "aws_route_table_association" "tf_rt_ass" {
  for_each = tomap({
    sn1_id = aws_subnet.tf_sn["${var.sn_cidr_blocks[0]}"].id
    sn2_id = aws_subnet.tf_sn["${var.sn_cidr_blocks[1]}"].id
  })
  subnet_id      = each.value
  route_table_id = aws_route_table.tf_rt.id
}