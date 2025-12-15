# 테라폼 블록
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

# 프로바이더 블록
provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

# 리소스 블록 - VPC
// VPC 생성
resource "aws_vpc" "tf_vpc" {
  cidr_block = local.seoul.vpc_cidr

  tags = {
    Name = "${local.seoul.pjt_name}_vpc"
  }
}

// IGW 생성
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
  }
}

// 서브넷 생성
resource "aws_subnet" "tf_pub_sn" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = local.seoul.sn_cidr
  availability_zone = local.seoul.az

  tags = {
    Name = "${local.seoul.pjt_name}_pub_sn"
  }
}

// 라우팅 테이블 생성
resource "aws_route_table" "tf_pub_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "${local.seoul.pjt_name}_pub_rt"
  }
}

resource "aws_route_table_association" "tf_pub_rt_ass" {
  subnet_id      = aws_subnet.tf_pub_sn.id
  route_table_id = aws_route_table.tf_pub_rt.id
}

// 보안그룹 생성
resource "aws_security_group" "tf_ec2_sg" {
  name        = "terraform pub security group"
  description = "terraform pub security group"
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "${local.seoul.pjt_name}_pub_sg"
  }
}

resource "aws_security_group_rule" "tf_pub_sg_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
}

resource "aws_security_group_rule" "tf_pub_sg_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
}

resource "aws_security_group_rule" "tf_pub_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
}

// 인스턴스 생성
resource "aws_instance" "tf_web" {
  ami                         = local.seoul.ami
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.tf_pub_sn.id
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]

  tags = {
    Name = "${local.seoul.pjt_name}-web"
  }

  user_data = <<-EOT
  #!/bin/bash
  echo "p@ssw0rd" | passwd --stdin root
  sed -i "s/^#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
  sed -i "s/^PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  systemctl restart sshd
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>${local.seoul.region} TEST Web Server</h1>" > /var/www/html/index.html
  EOT
}