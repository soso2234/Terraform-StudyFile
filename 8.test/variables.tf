# 변수 블록
variable "pjt_name" {
  type        = string
  description = "프로젝트 이름?"
  default     = "terraform"
}

variable "region_name" {
  description = "region_name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "sn_cidr1" {
  description = "Subnet CIDR"
  type        = string
}

variable "sn_cidr2" {
  description = "Subnet CIDR"
  type        = string
}

variable "sn_cidr3" {
  description = "Subnet CIDR"
  type        = string
}

variable "sn_cidr4" {
  description = "Subnet CIDR"
  type        = string
}

variable "availability_zone_a" {
  description = "availability_zone_a"
  type        = string
}

variable "availability_zone_c" {
  description = "availability_zone_c"
  type        = string
}

variable "enable_dns_support" {
  description = "enable_dns_support"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "enable_dns_hostnames"
  type        = bool
  default     = true
}

variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "instance_type"
  type        = string
  default     = "t3.micro"
}

variable "cidr_ipv4" {
  description = "cidr_ipv4"
  type        = string
  default     = "0.0.0.0/0"
}
