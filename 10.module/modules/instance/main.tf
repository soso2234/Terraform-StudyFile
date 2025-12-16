// 인스턴스 생성
resource "aws_instance" "tf_web" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = var.sn_id
  vpc_security_group_ids      = var.sg_ids

  tags = {
    Name = "${var.pjt_name}-web"
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
  echo "<h1>TEST Web Server</h1>" > /var/www/html/index.html
  EOT
}