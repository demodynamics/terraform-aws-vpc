variable "project" {
  description = "Project Name"
  type = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type  = string
}

variable "route_cidr" {
  description = "The CIDR block of the route tables"
  type = string  
}

variable "az_count" {
  description = "The number of AZs to create in"
  type = number
  
}

variable "vpc_dns" {
  description = "VPC DNS Support Status"
  type = bool
}

variable "map_public_ip_on_launch" {
  description = "Public IP on auto creation status"
  type = bool
  
}

variable "single_natgw" {
  description = "Creae single Nat Gateway for all Private Subnets"
  type = bool
}

variable "natgw_per_az" {
  description = "Creae Nat Gateway for Private Subnets per AZs count"
  type = bool
  
}

variable "natgw_per_subnet" {
  description = "Creae Nat Gateway for each Private Subnet"
  type = bool
  
}

variable "subnets_count" {
  description = "Total Number of subnets (Private and Public) to create"
  type = number
  
}

variable "public_subnets_count" {
  description = "Number of public subnets to create"
  type = number
}

variable "private_subnets_count" {
  description = "Number of private subnets to create"
  type = number
}

variable "subnet_prefix" {
  description = "Prefix for subnet creation"
  type = number
  
}

variable "sg_ports" {
  description = "Ports to open for ingress on Security Group"
  type = list(number)
}

variable "default_tags" {
  description = "Default Tags to apply to all resources"
  type = map(string)
  
}

variable "public_route_per_sub" {
  description = "Create Public Route Table per Public Subnet"
  type = bool
}