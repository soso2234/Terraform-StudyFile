terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_vpc" "Test" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TEST"
  }
}