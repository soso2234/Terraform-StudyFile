variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "pjt_name" {
  type    = string
  default = "tf"
}

variable "vpc_cidr_block" {
  type = string
}

variable "ami" {
  type    = string
  default = "ami-0b818a04bc9c2133c"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}