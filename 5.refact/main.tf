# 테라폼 블록 (생략 가능 - 최신버전 적용)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}

# 프로바이더 블록
provider "aws" {
  # Configuration options
}

# 변수 블록
variable "pjt_name" {
  type        = string
  description = "프로젝트 이름?"
  default     = "terraform"
}

# 리소스 블록(필수)
// VPC 생성
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.pjt_name}-vpc"
  }
}

// IGW 생성
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.pjt_name}-igw"
  }
}

// 퍼블릭 서브넷 생성
resource "aws_subnet" "tf_sn" {
  for_each = tomap({
    "172.16.1.0/24" = "ap-northeast-2a",
    "172.16.2.0/24" = "ap-northeast-2c",
    "172.16.3.0/24" = "ap-northeast-2a",
    "172.16.4.0/24" = "ap-northeast-2c"
  })
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = each.key
  availability_zone = each.value

  tags = {
    Name = "${var.pjt_name}-${each.key}-sn"
  }
}

// 퍼블릭 라이팅 테이블 생성
resource "aws_route_table" "tf_pub_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "${var.pjt_name}-pub-rt"
  }
}

// 퍼블릭 라우팅 테이블에 서브넷 연결
resource "aws_route_table_association" "tf_pub_rt_ass" {
  for_each = tomap({
    pub_sn1_id = aws_subnet.tf_sn["172.16.1.0/24"].id,
    pub_sn2_id = aws_subnet.tf_sn["172.16.2.0/24"].id
  })
  subnet_id      = each.value
  route_table_id = aws_route_table.tf_pub_rt.id
}

// 프라이빗 라이팅 테이블 생성
resource "aws_route_table" "tf_pri_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.pjt_name}-pri-rt"
  }
}

// 프라이빗 라우팅 테이블에 서브넷 연결
resource "aws_route_table_association" "tf_pri_rt_ass" {
  for_each = tomap({
    pri_sn3_id = aws_subnet.tf_sn["172.16.3.0/24"].id,
    pri_sn4_id = aws_subnet.tf_sn["172.16.4.0/24"].id
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
  subnet_id     = aws_subnet.tf_sn["172.16.1.0/24"].id

  tags = {
    Name = "${var.pjt_name}-nat-gw"
  }
  depends_on = [aws_internet_gateway.tf_igw]
}

// 프라이빗 라우팅 테이블에 기본 경로 설정
resource "aws_route" "tf_pri_rt_route" {
  route_table_id         = aws_route_table.tf_pri_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tf_nat_gw.id
  depends_on             = [aws_nat_gateway.tf_nat_gw]
}

// EC2 웹서버가 사용할 보안 그룹 생성
resource "aws_security_group" "tf_ec2_sg" {
  name        = "tf_ec2_sg"
  description = "Allow SSH, HTTP"
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "{var.pjt_name}-ec2-sg"
  }
}

// EC2 보안그룹에 SSH 인바운드 규칙 추가
resource "aws_vpc_security_group_ingress_rule" "tf_ec2_sg_ssh" {
  security_group_id = aws_security_group.tf_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

// EC2 보안그룹에 HTTP 인바운드 규칙 추가
resource "aws_vpc_security_group_ingress_rule" "tf_ec2_sg_http" {
  security_group_id = aws_security_group.tf_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
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
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "{var.pjt_name}-alb-sg"
  }
}

// ALB 보안그룹에 HTTP 인바운드 규칙 추가
resource "aws_vpc_security_group_ingress_rule" "tf_alb_sg_http" {
  security_group_id = aws_security_group.tf_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

// ALB 보안그룹에 HTTPS 인바운드 규칙 추가
resource "aws_vpc_security_group_ingress_rule" "tf_alb_sg_https" {
  security_group_id = aws_security_group.tf_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

// ALB 보안그룹에 아웃바운드 규칙 추가
resource "aws_vpc_security_group_egress_rule" "tf_alb_sg_egress" {
  security_group_id = aws_security_group.tf_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

// EC2 인스턴스1 생성
resource "aws_instance" "tf_ec2_1" {
  ami                         = "ami-0b818a04bc9c2133c"
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.tf_sn["172.16.3.0/24"].id
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]
  depends_on                  = [aws_nat_gateway.tf_nat_gw]
  key_name                    = "tf-key"
  user_data                   = <<-EOT
  #!/bin/bash
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>TEST Web Server 1</h1>" > /var/www/html/index.html
  EOT

  tags = {
    Name = "${var.pjt_name}-ec2-1"
  }
}

// EC2 인스턴스2 생성
resource "aws_instance" "tf_ec2_2" {
  ami                         = "ami-0b818a04bc9c2133c"
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.tf_sn["172.16.4.0/24"].id
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]
  depends_on                  = [aws_nat_gateway.tf_nat_gw]
  key_name                    = "tf-key"
  user_data                   = <<-EOT
  #!/bin/bash
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>TEST Web Server 2</h1>" > /var/www/html/index.html
  EOT

  tags = {
    Name = "${var.pjt_name}-ec2-2"
  }
}

// 대상 그룹 생성
resource "aws_lb_target_group" "tf_tg" {
  name     = "tf-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_vpc.id
}

// 대상 그룹에 대상 지정
resource "aws_lb_target_group_attachment" "tf_tg_ec2_att_1" {
  target_group_arn = aws_lb_target_group.tf_tg.arn
  target_id        = aws_instance.tf_ec2_1.id
  port             = 80
  depends_on       = [aws_instance.tf_ec2_1]
}

resource "aws_lb_target_group_attachment" "tf_tg_ec2_att_2" {
  target_group_arn = aws_lb_target_group.tf_tg.arn
  target_id        = aws_instance.tf_ec2_2.id
  port             = 80
  depends_on       = [aws_instance.tf_ec2_2]
}

// 리스너 생성
resource "aws_lb_listener" "tf_web_listener" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_tg.arn
  }
}

// ALB 생성
resource "aws_lb" "tf_alb" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf_alb_sg.id]
  subnets = [
    aws_subnet.tf_sn["172.16.1.0/24"].id,
    aws_subnet.tf_sn["172.16.2.0/24"].id
  ]
  enable_deletion_protection = false

  tags = {
    Name = "${var.pjt_name}_alb"
  }
}