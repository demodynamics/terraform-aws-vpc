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
  count = local.public_route_count
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
  route_table_id = aws_route_table.public[count.index % local.public_route_count].id
}

/*
When local.public_route_count = 1, it means there is only one route table (aws_route_table.public[0]).

Behavior of count.index % 1
count.index % 1 always results in 0 regardless of count.index because any number modulo 1 is always 0.

Example Calculation:
If count.index iterates over multiple subnets (count = local.set.public_cidr_count), let's see how % 1 behaves:

count.index	   count.index % 1	     Selected aws_route_table.public Index
0	             0 % 1 = 0	           aws_route_table.public[0]
1	             1 % 1 = 0	           aws_route_table.public[0]
2	             2 % 1 = 0	           aws_route_table.public[0]
3	             3 % 1 = 0	           aws_route_table.public[0]
n	             n % 1 = 0	           aws_route_table.public[0]

Since public_route_count = 1, Terraform only creates one route table (aws_route_table.public[0]).
Thus, every subnet will always be associated with aws_route_table.public[0].id.



When local.public_route_count > 1, it means there will be more than one route table (aws_route_table.public[n]).
 For example : local.public_route_count = 4

Behavior of count.index % 1
count.index % 1  will distribute subnets across multiple route tables.

Example Calculation:
If count.index iterates over multiple subnets (count = local.set.public_cidr_count), let's see how % 4 behaves:

count.index	   count.index % 1	     Selected aws_route_table.public Index
0	             0 % 4 = 0	           aws_route_table.public[0]
1	             1 % 4 = 1	           aws_route_table.public[1]
2	             2 % 4 = 2	           aws_route_table.public[2]
3	             3 % 4 = 3	           aws_route_table.public[3]
4	             4 % 4 = 3	           aws_route_table.public[0]
5	             5 % 4 = 3	           aws_route_table.public[1]
6	             6 % 4 = 2	           aws_route_table.public[2]
7	             7 % 4 = 3	           aws_route_table.public[3]
8	             8 % 4 = 0	           aws_route_table.public[0]
9	             9 % 4 = 1	           aws_route_table.public[1]
10	           10 % 4 = 2	           aws_route_table.public[2]
11	           11 % 4 = 3	           aws_route_table.public[3]
n	              n % 4 = 0 or 1 or 2 or 3  aws
*/



resource "aws_route_table_association" "private_association" {
  count          = local.count_rule!=0?local.set.private_cidr_count:0
  subnet_id      = aws_subnet.private[count.index].id # Required: Subnet ID
  route_table_id = aws_route_table.private[count.index % local.count_rule].id
}
