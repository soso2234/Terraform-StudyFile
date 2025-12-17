variable "region" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "instance_id1" {
  type    = string
  default = ""
}

variable "instance_id2" {
  type    = string
  default = ""
}

variable "sg_id" {
  type    = list(any)
  default = []
}

variable "sn_id" {
  type    = list(any)
  default = []
}

variable "pjt_name" {
  type    = string
  default = ""
}