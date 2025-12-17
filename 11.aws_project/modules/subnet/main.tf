resource "aws_subnet" "tf_sn" {
  for_each = tomap({
    pub_sn1 = ["172.16.1.0/24", "ap-northeast-2a", "pub1"],
    pub_sn2 = ["172.16.2.0/24", "ap-northeast-2c", "pub2"],
    pri_sn3 = ["172.16.3.0/24", "ap-northeast-2a", "pri3"],
    pri_sn4 = ["172.16.4.0/24", "ap-northeast-2c", "pri4"]
  })
  vpc_id            = var.vpc_id
  cidr_block        = each.value[0]
  availability_zone = each.value[1]

  tags = {
    Name = "${var.pjt_name}-${each.key}"
  }
}