data "aws_availability_zones" "availablaibilty_zones" {}


resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_base
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = tomap({
    "Name" = "${var.environment}-${var.app_name}"
  })
}

/*====
Subnets
======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}-${var.app_name}-igw"
    Environment = "${var.environment}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]

  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = tomap({
    "Name" = "${var.environment}-${var.app_name}-public-subnet"
  })
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = tomap({
    "Name" = "${var.environment}-${var.app_name}-private-subnet"
  })
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

/* Route table associations */
resource "aws_main_route_table_association" "vpc" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# /*====
# Security Group for ECS
# ======*/

resource "aws_security_group" "ecs_sg" {
  name        = "${var.environment}-${var.app_name}-ecs-sg"
  description = "Managed by Terraform"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-${var.app_name}-ecs-sg"
  }
}