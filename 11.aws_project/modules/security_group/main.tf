// EC2 웹서버가 사용할 보안 그룹 생성
resource "aws_security_group" "tf_ec2_sg" {
  name        = "tf_ec2_sg"
  description = "Allow SSH, HTTP"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.pjt_name}-ec2-sg"
  }
}

// EC2 보안그룹에 인바운드 규칙 추가
resource "aws_vpc_security_group_ingress_rule" "tf_ec2_sg_ingress" {
  for_each = toset(["22", "80", "443"])

  security_group_id = aws_security_group.tf_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  to_port           = each.value
  from_port         = each.value
}

// EC2 보안그룹에 아웃바운드 규칙 추가
resource "aws_vpc_security_group_egress_rule" "tf_ec2_sg_egress" {
  security_group_id = aws_security_group.tf_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

// ALB가 사용할 보안 그룹 생성
resource "aws_security_group" "tf_alb_sg" {
  name        = "tf_alb_sg"
  description = "Allow HTTP, HTTPS"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.pjt_name}-alb-sg"
  }
}

// ALB 보안그룹에 HTTP 인바운드 규칙 추가
resource "aws_vpc_security_group_ingress_rule" "tf_alb_sg_ingress" {
  for_each = toset(["22", "80", "443"])

  security_group_id = aws_security_group.tf_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  to_port           = each.value
  from_port         = each.value
}


// ALB 보안그룹에 아웃바운드 규칙 추가
resource "aws_vpc_security_group_egress_rule" "tf_alb_sg_egress" {
  security_group_id = aws_security_group.tf_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}