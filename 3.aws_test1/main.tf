# terraform block (생략 가능)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}

# provider block
provider "aws" {
  # Configuration options
}

# variable block
variable "pjt_name" {
  type        = string
  description = "project name?"
  default     = "Terraform"
}

# resource block
// Create VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.pjt_name}-vpc"
  }
}

// Create IGW
resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "${var.pjt_name}-igw"
  }
}

// Create pub-sn1
resource "aws_subnet" "tf-pub-sn1" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.pjt_name}-pub-sn1"
  }
}

// Create pub-sn2
resource "aws_subnet" "tf-pub-sn2" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.pjt_name}-pub-sn2"
  }
}

// Create pri-sn3
resource "aws_subnet" "tf-pri-sn3" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "172.16.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.pjt_name}-pri-sn3"
  }
}

// Create pri-sn4
resource "aws_subnet" "tf-pri-sn4" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "172.16.4.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.pjt_name}-pri-sn4"
  }
}

// Create Public-Routetable
resource "aws_route_table" "tf-pub-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id
  }

  tags = {
    Name = "${var.pjt_name}-pub-rt"
  }
}

// Assosiation RouteTable-Subnet
resource "aws_route_table_association" "tf-pub-rt-ass1" {
  subnet_id      = aws_subnet.tf-pub-sn1.id
  route_table_id = aws_route_table.tf-pub-rt.id
}

resource "aws_route_table_association" "tf-pub-rt-ass2" {
  subnet_id      = aws_subnet.tf-pub-sn2.id
  route_table_id = aws_route_table.tf-pub-rt.id
}

// Create Private-Routetable
resource "aws_route_table" "tf-pri-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "${var.pjt_name}-pri-rt"
  }
}

// Assosiation RouteTable-Subnet
resource "aws_route_table_association" "tf-pri-rt-ass3" {
  subnet_id      = aws_subnet.tf-pri-sn3.id
  route_table_id = aws_route_table.tf-pri-rt.id
}

resource "aws_route_table_association" "tf-pri-rt-ass4" {
  subnet_id      = aws_subnet.tf-pri-sn4.id
  route_table_id = aws_route_table.tf-pri-rt.id
}

// Create EIP
resource "aws_eip" "tf-nat-eip" {
  tags = {
    Name = "${var.pjt_name}-nat-eip"
  }
}

// Create NAT Gateway
resource "aws_nat_gateway" "tf-nat-gw" {
  allocation_id = aws_eip.tf-nat-eip.id
  subnet_id     = aws_subnet.tf-pub-sn1.id

  tags = {
    Name = "${var.pjt_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.tf-igw]
}

// PrivateRt Basic Route
resource "aws_route" "tf-pri-rt-route" {
  route_table_id         = aws_route_table.tf-pri-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tf-nat-gw.id

  depends_on = [aws_nat_gateway.tf-nat-gw]
}

// Create Security Group by EC2
resource "aws_security_group" "tf-ec2-sg" {
  name        = "tf-ec2-sg"
  description = "Allow SSH, HTTP"
  vpc_id      = aws_vpc.tf-vpc.id

  tags = {
    Name = "${var.pjt_name}-ec2-sg"
  }
}

// EC2 Security Group add SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "tf-ec2-sg-ssh" {
  security_group_id = aws_security_group.tf-ec2-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

// EC2 Security Group add HTTP inbound rule
resource "aws_vpc_security_group_ingress_rule" "tf-ec2-sg-http" {
  security_group_id = aws_security_group.tf-ec2-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

// EC2 Security Group add outbound rule
resource "aws_vpc_security_group_egress_rule" "tf-ec2-sg-egress" {
  security_group_id = aws_security_group.tf-ec2-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

// Create Security Group by ALB
resource "aws_security_group" "tf-alb-sg" {
  name        = "tf-alb-sg"
  description = "Allow HTTP, HTTPS"
  vpc_id      = aws_vpc.tf-vpc.id

  tags = {
    Name = "${var.pjt_name}-alb-sg"
  }
}

// ALB Security Group add HTTP inbound rule
resource "aws_vpc_security_group_ingress_rule" "tf-alb-sg-http" {
  security_group_id = aws_security_group.tf-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

// ALB Security Group add HTTPS inbound rule
resource "aws_vpc_security_group_ingress_rule" "tf-alb-sg-https" {
  security_group_id = aws_security_group.tf-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

// ALB Security Group add outbound rule
resource "aws_vpc_security_group_egress_rule" "tf-alb-sg-egress" {
  security_group_id = aws_security_group.tf-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

// Create EC2 Instance
resource "aws_instance" "tf-ec2-1" {
  ami                         = "ami-0b818a04bc9c2133c"
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.tf-pri-sn3.id
  vpc_security_group_ids      = [aws_security_group.tf-ec2-sg.id]
  depends_on                  = [aws_nat_gateway.tf-nat-gw]
  key_name                    = "tf-key"
  user_data                   = <<-EOF
  #!/bin/bash
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>TEST WEB Server 1</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.pjt_name}-ec2-1"
  }
}

resource "aws_instance" "tf-ec2-2" {
  ami                         = "ami-0b818a04bc9c2133c"
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.tf-pri-sn4.id
  vpc_security_group_ids      = [aws_security_group.tf-ec2-sg.id]
  depends_on                  = [aws_nat_gateway.tf-nat-gw]
  key_name                    = "tf-key"
  user_data                   = <<-EOF
  #!/bin/bash
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>TEST WEB Server 2</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.pjt_name}-ec2-2"
  }
}

// Create Target Group
resource "aws_lb_target_group" "tf-tg" {
  name     = "tf-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf-vpc.id
}

// Target Group Attache
resource "aws_lb_target_group_attachment" "tf-tg-ec2-att-1" {
  target_group_arn = aws_lb_target_group.tf-tg.arn
  target_id        = aws_instance.tf-ec2-1.id
  port             = 80
  depends_on       = [aws_instance.tf-ec2-1]
}

resource "aws_lb_target_group_attachment" "tf-tg-ec2-att-2" {
  target_group_arn = aws_lb_target_group.tf-tg.arn
  target_id        = aws_instance.tf-ec2-2.id
  port             = 80
  depends_on       = [aws_instance.tf-ec2-2]
}

// Create Listener
resource "aws_lb_listener" "tf-web-listener" {
  load_balancer_arn = aws_lb.tf-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-tg.arn
  }
}

// Create ALB
resource "aws_lb" "tf-alb" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf-alb-sg.id]
  subnets = [
    aws_subnet.tf-pub-sn1.id,
    aws_subnet.tf-pub-sn2.id
  ]
  enable_deletion_protection = false

  tags = {
    Name = "${var.pjt_name}-alb"
  }
}