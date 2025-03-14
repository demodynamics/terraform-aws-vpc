output "vpc_data" {
  value = {
    "VPC ID" = aws_vpc.main.id
    "VPC Inetrnet Gateway ID" = aws_internet_gateway.igw.id
    "Subnet ID's"             = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    "Public Subnet ID"        = aws_subnet.public[*].id
    "Public Subenet AZNames"  = aws_subnet.public[*].availability_zone
    "Private Subnet ID"       = aws_subnet.private[*].id
    "Private Subenet AZNames" = aws_subnet.private[*].availability_zone
  }
}


/*
output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main.id
}

# 
output "subnet_ids" {
  description = "List of Subnet ID's"
  value = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
}

# This is output structure is a map with list values.
output "public_subnet" {
  description = "Map of Public Subnet IDs list and Public Subnet AZs list"
  value = {
     ID = aws_subnet.public[*].id
     AZName = aws_subnet.public[*].availability_zone

  }
}

output "private_subnet" {
  description = "VPC Private Subnets"
  value = {
     ID = aws_subnet.private[*].id
     AZName = aws_subnet.private[*].availability_zone

  }
}

output "internet_gateway_id" {
  description = "VPC Inetrnet Gateway"
  value = aws_internet_gateway.igw.id
}
*/

