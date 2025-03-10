project                 = "Project"
vpc_cidr                = "10.0.0.0/16"
subnets_count           = 4
subnet_prefix           = 24
public_subnets_count    = 2
private_subnets_count   = 2
route_cidr              = "0.0.0.0/0"
az_desired_count        = 2 # Before adding a count of desired az's be sure that it is not more than the total number of available AZ's in the region
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
