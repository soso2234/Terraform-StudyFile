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
  type    = string
  default = ""
}

variable "sg_ids" {
  type    = list
  default = []
}

variable "pjt_name" {
  type    = string
  default = ""
}