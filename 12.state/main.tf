terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.27.0"
    }
  }
  backend "s3" {
    bucket = "terraform-test-1454"
    key    = "terraform.tfstate"
    region = "ap-northeast-2"
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# 변수 블록
variable "users" {
  type = list(any)
}

# 리소스 블록
// 그룹 생성
resource "aws_iam_group" "devs" {
  name = "devs"
}
resource "aws_iam_group" "emps" {
  name = "emps"
}

// 사용자 생성
resource "aws_iam_user" "test_users" {
  for_each = tomap({
    for user in var.users : user.name => user
  })
  name = each.key

  tags = {
    Name = each.value.name
    Role = each.value.role
    Is_dev = each.value.is_dev
  }
}

// 사용자 역할에 따라 사용자 그룹에 소속
resource "aws_iam_user_group_membership" "team" {
  for_each = tomap({
    for user in var.users : user.name => user
  })
  user = each.key

  groups = each.value.is_dev ? [aws_iam_group.devs.name, aws_iam_group.emps.name] : [aws_iam_group.emps.name]
}