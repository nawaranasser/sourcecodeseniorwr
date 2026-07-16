variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "vprofile"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type used for the Docker Compose host."
  type        = string
  default     = "t3.medium"
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform."
  type        = string
  default     = "vprofile"
}

variable "ecr_force_delete" {
  description = "Allow Terraform to delete the ECR repository even when it contains images."
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR block used by the VProfile VPC."
  type        = string
  default     = "10.0.0.0/16"
}