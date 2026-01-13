region_name    = "ap-southeast-2"
pjt_name       = "sydney"
vpc_cidr_block = "172.17.0.0/16"
subnets = {
  "172.17.1.0/24" = "ap-southeast-2a"
  "172.17.2.0/24" = "ap-southeast-2c"
}

sn_cidr_blocks = [
  "172.17.1.0/24",
  "172.17.2.0/24"
]