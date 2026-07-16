# Resources will be added step by step.
# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

# ============================================================
# Internet Gateway
# ============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# ============================================================
# Public Subnets
# ============================================================

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  # We do not want EC2 instances to receive public IPs automatically.
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-public-a"
    Tier = "public"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-public-b"
    Tier = "public"
  }
}

# ============================================================
# Private Application Subnets
# ============================================================

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-private-a"
    Tier = "private"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-private-b"
    Tier = "private"
  }
}

# ============================================================
# Public Route Tables
# Each public subnet has its own route table for clarity.
# ============================================================

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-public-a-rt"
  }
}

resource "aws_route" "public_a_internet" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-public-b-rt"
  }
}

resource "aws_route" "public_b_internet" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id
}

# ============================================================
# Private Route Tables
# No default internet route yet.
# NAT Gateway will be added in the next networking step.
# ============================================================

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-private-a-rt"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-private-b-rt"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

# ============================================================
# NAT Gateway
#
# Development design:
# - One zonal NAT Gateway in public subnet A.
# - Both private subnets use it for outbound internet access.
#
# Production HA improvement:
# - Use one NAT Gateway per Availability Zone, or
# - Use a Regional NAT Gateway.
# ============================================================

resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-a-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id     = aws_eip.nat_a.id
  subnet_id         = aws_subnet.public_a.id
  connectivity_type = "public"

  tags = {
    Name = "${local.name_prefix}-nat-a"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}

# ============================================================
# Private subnet default routes
# ============================================================

resource "aws_route" "private_a_internet" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route" "private_b_internet" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}