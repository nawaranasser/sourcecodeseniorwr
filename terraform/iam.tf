# Resources will be added step by step.
# ============================================================
# EC2 trust policy
# Allows the EC2 service to assume this IAM role.
# ============================================================

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ============================================================
# Application EC2 IAM Role
# ============================================================

resource "aws_iam_role" "app_ec2" {
  name               = "${local.name_prefix}-app-ec2-role"
  description        = "IAM role used by VProfile application EC2 instances."
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${local.name_prefix}-app-ec2-role"
  }
}

# ============================================================
# Least-privilege ECR pull policy
#
# GetAuthorizationToken must use Resource "*".
# Image pull actions are restricted to our application repository.
# ============================================================

data "aws_iam_policy_document" "app_ecr_pull" {
  statement {
    sid    = "GetECRAuthorizationToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PullVProfileApplicationImage"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]

    resources = [
      aws_ecr_repository.app.arn
    ]
  }
}

resource "aws_iam_policy" "app_ecr_pull" {
  name        = "${local.name_prefix}-app-ecr-pull"
  description = "Allows VProfile EC2 instances to pull the application image from ECR."
  policy      = data.aws_iam_policy_document.app_ecr_pull.json

  tags = {
    Name = "${local.name_prefix}-app-ecr-pull"
  }
}

# ============================================================
# Attach Systems Manager permissions
# ============================================================

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================================
# Attach ECR pull permissions
# ============================================================

resource "aws_iam_role_policy_attachment" "app_ecr_pull" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = aws_iam_policy.app_ecr_pull.arn
}

# ============================================================
# EC2 Instance Profile
#
# EC2 resources receive the instance profile, not the role directly.
# ============================================================

resource "aws_iam_instance_profile" "app_ec2" {
  name = "${local.name_prefix}-app-ec2-profile"
  role = aws_iam_role.app_ec2.name

  tags = {
    Name = "${local.name_prefix}-app-ec2-profile"
  }
}