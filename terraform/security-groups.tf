# Resources will be added step by step.
# ============================================================
# ALB Security Group
# ============================================================

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Controls inbound and outbound traffic for the VProfile ALB."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# Public users can access the ALB over HTTP.
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP traffic from the internet."

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# The ALB can forward application traffic and health checks
# only to instances using the application security group.
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow ALB traffic to the application on port 8080."

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# ============================================================
# Application EC2 Security Group
# ============================================================

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Controls traffic for the VProfile application EC2 instances."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-app-sg"
  }
}

# Application traffic is accepted only from the ALB.
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id = aws_security_group.app.id
  description       = "Allow Tomcat traffic only from the ALB."

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# The EC2 instance needs outbound access for:
# - ECR image pulls
# - Docker Hub image pulls
# - SSM communication
# - Operating system packages and updates
resource "aws_vpc_security_group_egress_rule" "app_outbound" {
  security_group_id = aws_security_group.app.id
  description       = "Allow application instances to initiate outbound traffic."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}