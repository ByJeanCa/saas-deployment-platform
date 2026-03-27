terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    { Name = format("VPC-%s-%s", var.project_name, var.region) },
    var.common_tags
  )
}

resource "aws_internet_gateway" "public_subnets" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = format("%s-gw-%s", var.project_name, var.region) },
    var.common_tags
  )
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

data "aws_availability_zones" "available" {}


locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)


  public_map = { for i, cidr in var.public_subnet_cidrs :
    i => { cidr = cidr, az = local.azs[i % length(local.azs)] }
  }

  private_map = { for i, cidr in var.private_subnet_cidrs :
  i => { cidr = cidr, az = local.azs[i % length(local.azs)] } }
}

resource "aws_subnet" "public" {

  for_each = local.public_map

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr

  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = var.common_tags
}

resource "aws_subnet" "private" {

  for_each = local.private_map

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr

  availability_zone = each.value.az

  tags = var.common_tags
  
}

locals {
  nat_public_subnet_key = sort(keys(aws_subnet.public))[0]
  private_subnet_key    = sort(keys(aws_subnet.private))[0]
}

resource "aws_nat_gateway" "nat_private_sub" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.public[local.nat_public_subnet_key].id
  connectivity_type = "public"

  tags = merge(
    var.common_tags,
    { Name = format("NAT-private-subnet-%s", var.region) }
  )
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_subnets.id
  }

  tags = merge(
    var.common_tags,
    { Name = "public-subnets-route-table" }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_private_sub.id
  }

  tags = merge(
    var.common_tags,
    { Name = "private-subnets-route-table" }
  )
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}
