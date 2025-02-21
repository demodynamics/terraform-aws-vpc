output "vpc_id" {
  description = "${var.project} VPC ID"
  value = aws_vpc.main.id
}

# This is output structure is a map with list values.
output "public_subnet" {
  description = "${var.project} VPC Public Subnets"
  value = {
     ID = aws_subnet.public[*].id
     AZName = aws_subnet.public[*].availability_zone

  }
}

output "private_subnet" {
  description = "${var.project} VPC Private Subnets"
  value = {
     ID = aws_subnet.private[*].id
     AZName = aws_subnet.private[*].availability_zone

  }
}

output "internet_gateway_id" {
  description = "${var.project} VPC Inetrnet Gateway"
  value = aws_internet_gateway.igw.id
}


