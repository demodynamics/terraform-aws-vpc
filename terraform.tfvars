project                 = "Project"
vpc_cidr                = "10.0.0.0/16"
subnets_count           = 2
subnet_prefix           = 24
public_subnets_count    = 1
private_subnets_count   = 1
route_cidr              = "0.0.0.0/0"
az_count                = 2
vpc_dns                 = true
map_public_ip_on_launch = true
public_route_per_sub    = false
single_natgw            = false
natgw_per_az            = false
natgw_per_subnet        = false
sg_ports = [80, 443]

default_tags = {
  Owner = "Owner"
  Environment = "Environment"
  Project = "Project"
}
