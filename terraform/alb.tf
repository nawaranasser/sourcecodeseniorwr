# Resources will be added step by step.
# ============================================================
# Internet-facing Application Load Balancer
# ============================================================

resource "aws_lb" "app" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  # Suitable for the development environment and terraform destroy.
  enable_deletion_protection = false

  # Reject malformed HTTP headers instead of forwarding them.
  drop_invalid_header_fields = true

  enable_http2 = true
  idle_timeout = 60

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

# ============================================================
# Application Target Group
#
# The application listens on port 8080.
# EC2 instances will be registered in the next step.
# ============================================================

resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-app-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  protocol_version     = "HTTP1"
  deregistration_delay = 30

  health_check {
    enabled = true

    protocol = "HTTP"
    port     = "traffic-port"
    path     = "/login"
    matcher  = "200"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${local.name_prefix}-app-tg"
  }
}

# ============================================================
# HTTP Listener
#
# Receives public HTTP traffic on port 80 and forwards it
# to the application target group on port 8080.
# ============================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = {
    Name = "${local.name_prefix}-http-listener"
  }
}