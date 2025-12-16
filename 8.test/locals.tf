locals {
  seoul = {
    pjt_name = "terraform"
    region   = "ap-northeast-2"
    vpc_cidr = "172.16.0.0/16"
    sn_cidr1 = "172.16.1.0/24"
    sn_cidr2 = "172.16.2.0/24"
    sn_cidr3 = "172.16.3.0/24"
    sn_cidr4 = "172.16.4.0/24"
    az_a     = "ap-northeast-2a"
    az_c     = "ap-northeast-2c"
    ami      = "ami-0b818a04bc9c2133c"
  }

  sydney = {
    region_name         = "ap-southeats-2"
    vpc_cidr            = "172.17.0.0/16"
    sn_cidr1            = "172.17.1.0/24"
    sn_cidr2            = "172.17.2.0/24"
    sn_cidr3            = "172.17.3.0/24"
    sn_cidr4            = "172.17.4.0/24"
    availability_zone_a = "ap-southeats-2a"
    availability_zone_c = "ap-southeats-2c"
    ami                 = "ami-0b3c832b6b7289e44"
  }
}