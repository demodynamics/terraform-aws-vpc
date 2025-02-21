terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


#------------- VPC -----------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.vpc_dns
  enable_dns_hostnames = var.vpc_dns
  tags = merge(var.default_tags, { Name = "${var.project} VPC"})
}
#---------------------------------------------Subnets--------------------------------------------
resource "aws_subnet" "public" {
  count                   = local.set.public_cidr_count!=0?local.set.public_cidr_count:0
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = element(local.az_rule, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
   
   #Adding new key "Name" and its value "Public Subnet ${count.index}" to default_tags
   tags = merge(var.default_tags, { Name = "Public Subnet ${count.index}" } ) 
}

resource "aws_subnet" "private" {
  count             = local.set.private_cidr_count!=0?local.set.private_cidr_count:0 # If we have count attribute in resource, so it means that it is returns a list of resources, so we have list of that type of resources.
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = element(local.az_rule, count.index)

 tags = merge(var.default_tags, { Name = "Private Subnet ${count.index}" } )
}

#----------------IGW--------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.default_tags, { Name = "${var.project} NAT Gateway" } )
}

#--------Elastic IP (Static Public IP)-------
resource "aws_eip" "nat_eip" {
  count      = local.count_rule
  domain     = "vpc"
  depends_on = [ aws_internet_gateway.igw ]
  tags = merge(var.default_tags, { Name = "Elastic IP ${count.index} for NAT Gateway ${count.index}" } )
}

#----------NAT Gateway------------------------------
resource "aws_nat_gateway" "nat" {
  count         = local.count_rule
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = merge(var.default_tags, { Name = "NAT Gateway ${count.index}" } )
}

#-------------Route Tables-----------------
resource "aws_route_table" "private" {
  count  = local.count_rule
  vpc_id = aws_vpc.main.id

  route {
     cidr_block     = var.route_cidr
     nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge(var.default_tags, { Name = "Private Route Table ${count.index}" } )
}

resource "aws_route_table" "public" {
  count = length(aws_subnet.public) > 0 ? 1 : 0 # Creating 1 route table for public subnets
  vpc_id = aws_vpc.main.id

  route {
     cidr_block     = var.route_cidr
     gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.default_tags, { Name = "Public Route Table" } )
}

#----------------- Route Tables Association ---------------------
resource "aws_route_table_association" "public_association" {
  count          = local.set.public_cidr_count
  subnet_id      = aws_subnet.public[count.index].id 
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private_association" {
  count          = local.count_rule!=0?local.set.private_cidr_count:0
  subnet_id      = aws_subnet.private[count.index].id # Required: Subnet ID
  route_table_id = aws_route_table.private[count.index % local.count_rule].id
}
