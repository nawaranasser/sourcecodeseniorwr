# Resources will be added step by step.
output "ecr_repository_name" {
  description = "Name of the application ECR repository."
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "URL used to tag, push, and pull the application image."
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the application ECR repository."
  value       = aws_ecr_repository.app.arn
}

output "vpc_id" {
  description = "ID of the VProfile VPC."
  value       = aws_vpc.main.id
}

output "availability_zones" {
  description = "Availability Zones used by the infrastructure."
  value = [
    aws_subnet.public_a.availability_zone,
    aws_subnet.public_b.availability_zone
  ]
}

output "public_subnet_ids" {
  description = "IDs of the public subnets used by the ALB."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private application subnets."
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "nat_gateway_id" {
  description = "ID of the development NAT Gateway."
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Elastic IP associated with the NAT Gateway."
  value       = aws_eip.nat_a.public_ip
}

output "alb_security_group_id" {
  description = "Security group ID associated with the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID associated with the application EC2 instances."
  value       = aws_security_group.app.id
}

output "app_ec2_iam_role_name" {
  description = "IAM role used by the VProfile application EC2 instances."
  value       = aws_iam_role.app_ec2.name
}

output "app_ec2_instance_profile_name" {
  description = "IAM instance profile attached to the application EC2 instances."
  value       = aws_iam_instance_profile.app_ec2.name
}

output "app_ecr_pull_policy_arn" {
  description = "ARN of the least-privilege ECR pull policy."
  value       = aws_iam_policy.app_ecr_pull.arn
}


output "alb_arn" {
  description = "ARN of the VProfile Application Load Balancer."
  value       = aws_lb.app.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the VProfile Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "Public HTTP URL of the VProfile Application Load Balancer."
  value       = "http://${aws_lb.app.dns_name}"
}

output "app_target_group_arn" {
  description = "ARN of the application target group."
  value       = aws_lb_target_group.app.arn
}

output "http_listener_arn" {
  description = "ARN of the public HTTP listener."
  value       = aws_lb_listener.http.arn
}