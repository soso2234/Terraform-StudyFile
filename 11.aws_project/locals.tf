locals {
  vpc_cidr_block = {
    "ap-northeast-2" = "172.16.0.0/16"
    "ap-southeast-2" = "172.17.0.0/16"
  }
  subnet = {
    "ap-northeast-2" = {
      "172.16.1.0/24" = "ap-northeast-2a"
      "172.16.2.0/24" = "ap-northeast-2c"
      "172.16.3.0/24" = "ap-northeast-2a"
      "172.16.4.0/24" = "ap-northeast-2c"
    }
    "ap-southeast-2" = {
      "172.17.1.0/24" = "ap-southeast-2a"
      "172.17.2.0/24" = "ap-southeast-2c"
      "172.17.3.0/24" = "ap-southeast-2a"
      "172.17.4.0/24" = "ap-southeast-2c"
    }
  }
}