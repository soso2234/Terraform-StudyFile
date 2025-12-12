terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

// for_each tomap 이용 subnet 4개 생성
resource "aws_subnet" "main_sn" {
  for_each = tomap({
    "10.0.1.0/24" = "ap-northeast-2a",
    "10.0.2.0/24" = "ap-northeast-2c",
    "10.0.3.0/24" = "ap-northeast-2a",
    "10.0.4.0/24" = "ap-northeast-2c"
  })
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = each.key
  availability_zone = each.value

  tags = {
    Name = "main-${each.key}"
  }
}