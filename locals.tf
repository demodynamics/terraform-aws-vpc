locals {
  /* Extracts 16 from "10.0.0.0/16" - Terraform's split() function splits a string into a list` ["10.0.0.0", "16"] based on a delimiter and  we access the second 
  element using [1]. In this case, "/" is the delimiter. 
  > split("/", "10.0.0.0/16")[1]   > tonumber(split("/", "10.0.0.0/16")[1]
  "16"                             16                                       */
  vpc_prefix_length = tonumber(split("/", var.vpc_cidr)[1])
  subnet_cidrs = [for i in range(var.subnets_count) : cidrsubnet(var.vpc_cidr, var.subnet_prefix - local.vpc_prefix_length, i)]

  # coalesce(var.public_subnets_count, 0): If var.public_subnets_count is null, it returns 0.  
  # != 0 -  Ensures the value is not 0. his effectively checks that var.public_subnets_count is not null and not 0 in a more concise way.
  # In Terraform (and most programming languages), the end index in a slice function is not included. So, when you use: slice(local.subnet_cidrs, 0, 3), It will return the elements from index 0 up to, but not including, index 3. That means it will return the elements at indices 0, 1, and 2—which is 3 elements in total.
  public_subnet_cidrs = coalesce(var.public_subnets_count, 0) != 0 ? slice(local.subnet_cidrs, 0, var.public_subnets_count) : [] 
  private_subnet_cidrs = coalesce(var.private_subnets_count, 0) != 0 ? slice(local.subnet_cidrs, var.public_subnets_count, var.subnets_count):[] # [] - Empty list

  # Theesea are long versions of the above conditions code for slice.
  //public_subnet_cidrs = var.public_subnets_count != 0 && var.public_subnets_count != null ? slice(local.subnet_cidrs, 0, var.public_subnets_count) : []
  //private_subnet_cidrs = var.private_subnets_count != 0 && var.private_subnets_count != null ? slice(local.subnet_cidrs, var.public_subnets_count, var.subnets_count):[]
}

#Nat Gateway status Conditions

# single_nat is now simply var.single_natgw, since it was true in all cases where var.single_natgw == true.
# Logical negations (!) replace explicit == false for better readability.
# Avoid unnecessary conditions that are always true when another condition is met
locals {
  nat_status = {
    per_az     = var.natgw_per_az && !var.natgw_per_subnet && !var.single_natgw
    per_subnet = !var.natgw_per_az && var.natgw_per_subnet && !var.single_natgw
    single_nat = var.single_natgw  # Covers all cases where single_natgw is true
  }
}


/* # Theesea are long versions of the above Nat Gateway status Conditions code
locals {
  nat_status = {
    per_az = var.natgw_per_az==true && var.natgw_per_subnet==false && var.single_natgw==false
    per_subnet = var.natgw_per_az==false && var.natgw_per_subnet==true && var.single_natgw==false
    single_nat = var.single_natgw==true && var.natgw_per_az==false && var.natgw_per_subnet==false
    single_nat = var.single_natgw==true && var.natgw_per_az==true && var.natgw_per_subnet==false
    single_nat = var.single_natgw==true && var.natgw_per_az==false && var.natgw_per_subnet==true
    single_nat = var.single_natgw==true && var.natgw_per_az==true && var.natgw_per_subnet==true
  }
  }
*/

locals {
  set = {
    az_by_az_count = [ # creating list of availability zones by length of seted availability zones count using modulo method.
      for x in range(var.az_count) : # If we want to use var.az_count without range, so var.az_count should be a list or a range. (range(var.az_count)) is correct and recommended because It avoids errors when var.az_count is a number and ensures Terraform can iterate properly.
      element(data.aws_availability_zones.available.names, x % var.az_count) # As In this case, asvar.az_count is a number, x would be itterate in range of that number, and would be and index from that range. For example ` if var.az_count is 3, x would be 0, 1, 2`
                                                                             # So, if var.az_count would be alist, x would be an element from that list. x would be an object from var.az_count list, not an object that contains element from var.az_count list. For example , if var.az_count is ["a", "b", "c"], x would be "a", "b", "c" and not {"a", "b", "c"}
      ]                                                                      

      az_by_subnet_count = [ # creating list of availability zones by maximum of length of seted private and public subntes using modulo method.
      for x in range(max(length(local.public_subnet_cidrs), length(local.private_subnet_cidrs))) : 
      element(data.aws_availability_zones.available.names, x % var.az_count)
      ]


    # az_by_divide = [
    #   for x in range(length(local.private_subnet_cidrs)) : 
    #   element(data.aws_availability_zones.available.names, floor(x / var.az_count))
    #   ]
    az_count = var.az_count

    public_cidr_count = length(local.public_subnet_cidrs)
    private_cidr_count = length(local.private_subnet_cidrs)


    }
  }

locals {
   az_rule = local.nat_status.per_az?local.set.az_by_az_count:local.nat_status.per_subnet?local.set.az_by_subnet_count:local.nat_status.single_nat?local.set.az_by_subnet_count:local.set.az_by_subnet_count
}

locals {
   count_rule = local.nat_status.per_az?local.set.az_count:local.nat_status.per_subnet?min(local.set.public_cidr_count, local.set.private_cidr_count):local.nat_status.single_nat?1:0
}
 