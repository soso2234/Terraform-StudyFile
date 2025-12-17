variable "region" {
  type    = string
  default = ""
}

variable "ami" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = ""
}

variable "sn_id" {
  type    = list
  default = []
}

variable "sg_ids" {
  type    = list
  default = []
}

variable "pjt_name" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}