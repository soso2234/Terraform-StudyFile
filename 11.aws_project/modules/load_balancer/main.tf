// 대상 그룹 생성
resource "aws_lb_target_group" "tf_tg" {
  name     = "tf-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# // 대상 그룹에 대상 지정
resource "aws_lb_target_group_attachment" "tf_tg_ec2_att_1" {
  target_group_arn = aws_lb_target_group.tf_tg.arn
  target_id        = var.instance_id1
  port             = 80
}

resource "aws_lb_target_group_attachment" "tf_tg_ec2_att_2" {
  target_group_arn = aws_lb_target_group.tf_tg.arn
  target_id        = var.instance_id2
  port             = 80
}

# // 리스너 생성
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
  security_groups    = var.sg_id
  subnets = [
    var.sn_id[0],
    var.sn_id[1]
  ]
  enable_deletion_protection = false

  tags = {
    Name = "${var.pjt_name}_alb"
  }
}