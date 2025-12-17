resource "aws_vpc" "tf_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.pjt_name}-vpc"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  count = var.creat_igw ? 1 : 0
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.pjt_name}-igw"
  }
}