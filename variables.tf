variable "my_vpc_name" {
  type = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type  = string
}

variable "route_cidr" {
  description = "The CIDR block for the route table"
  type = string  
}

variable "az_count" {
  type = number
  
}

variable "vpc_dns" {
  type = bool
}

variable "map_public_ip_on_launch" {
  type = bool
  
}

variable "single_natgw" {
  type = bool
}

variable "natgw_per_az" {
  type = bool
  
}

variable "natgw_per_subnet" {
  type = bool
  
}

variable "subnets_count" {
  type = number
  
}

variable "public_subnets_count" {
  type = number
}

variable "private_subnets_count" {
  type = number
}

variable "subnet_prefix" {
  type = number
  
}

variable "sg_ports" {
  type = list(number)
}

variable "default_tags" {
  type = map(string)
  
}