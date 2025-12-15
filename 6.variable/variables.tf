# 변수 블록
variable "pjt_name" {
  description = "project name?"
  type        = string
  default     = "terraform"

}

variable "region_name" {
  description = "region_name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string

}

variable "sn_cidr" {
  description = "Subnet CIDR Block"
  type        = string

}

variable "az_name" {
  description = "AZ Name"
  type        = string

}

variable "ami_id" {
  description = "AMI ID"
  type        = string

}

variable "associate_public_ip" {
  description = "associate_public_ip"
  type        = bool
  default     = true

}