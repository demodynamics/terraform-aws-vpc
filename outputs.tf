output "vpc_id" {
  value = aws_vpc.demo_vpc.id
}

# This is output structure is a map with list values.
output "public_subnet" {
  value = {
     ID = aws_subnet.public[*].id
     AZName = aws_subnet.public[*].availability_zone

  }
}

output "private_subnet" {
  value = {
     ID = aws_subnet.private[*].id
     AZName = aws_subnet.private[*].availability_zone

  }
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}


