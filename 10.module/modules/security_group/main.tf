resource "aws_security_group" "tf_sg" {
  name        = "tf_pub_sg"
  description = "Allow SSH, HTTP"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.pjt_name}-sg"
  }
}

resource "aws_security_group_rule" "tf_sg_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_sg.id
}

resource "aws_security_group_rule" "tf_sg_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_sg.id
}

resource "aws_security_group_rule" "tf_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_sg.id
}