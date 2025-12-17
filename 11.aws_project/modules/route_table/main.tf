resource "aws_route_table" "tf_pub_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "${var.pjt_name}-pub-rt"
  }
}

// 퍼블릭 라우팅 테이블에 서브넷 연결
resource "aws_route_table_association" "tf_pub_rt_ass" {
  for_each = tomap({
    pub_sn1_id = var.sn_id[0]
    pub_sn2_id = var.sn_id[1]
  })
  subnet_id      = each.value
  route_table_id = aws_route_table.tf_pub_rt.id
}

resource "aws_route_table" "tf_pri_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.pjt_name}-pri-rt"
  }
}

// 프라이빗 라우팅 테이블에 서브넷 연결
resource "aws_route_table_association" "tf_pri_rt_ass" {
  for_each = tomap({
    pri_sn3_id = var.sn_id[2],
    pri_sn4_id = var.sn_id[3]
})
  subnet_id      = each.value
  route_table_id = aws_route_table.tf_pri_rt.id
}

// EIP 생성
resource "aws_eip" "tf_nat_eip" {
  tags = {
    Name = "${var.pjt_name}-nat-eip"
  }
}

// NAT 게이트웨이 생성
resource "aws_nat_gateway" "tf_nat_gw" {
  allocation_id = aws_eip.tf_nat_eip.id
  subnet_id     = var.sn_id[0]

  tags = {
    Name = "${var.pjt_name}-nat-gw"
  }
}

// 프라이빗 라우팅 테이블에 기본 경로 설정
resource "aws_route" "tf_pri_rt_route" {
  route_table_id         = aws_route_table.tf_pri_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tf_nat_gw.id
  depends_on             = [aws_nat_gateway.tf_nat_gw]
}