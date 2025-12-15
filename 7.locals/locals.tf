# 로컬 블록
locals {
  # ex) 로컬 이름 = 표현식
  seoul = {
    pjt_name = "terraform"
    region   = "ap-northeast-2"
    vpc_cidr = "10.0.0.0/16"
    sn_cidr  = "10.0.0.0/24"
    az       = "ap-northeast-2a"
    ami      = "ami-0b818a04bc9c2133c"
  }
}