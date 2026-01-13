region_name    = "ap-northeast-2"
pjt_name       = "seoul"
vpc_cidr_block = "172.16.0.0/16"
subnets = {
  "172.16.1.0/24" = "ap-northeast-2a"
  "172.16.2.0/24" = "ap-northeast-2c"
}

sn_cidr_blocks = [
  "172.16.1.0/24",
  "172.16.2.0/24"
]