// EC2 인스턴스1 생성
resource "aws_instance" "tf_ec2_1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = false
  subnet_id                   = var.sn_id[2]
  vpc_security_group_ids      = var.sg_ids
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
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = false
  subnet_id                   = var.sn_id[3]
  vpc_security_group_ids      = var.sg_ids
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

