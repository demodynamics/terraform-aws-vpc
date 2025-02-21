resource "aws_security_group" "demo_security_group" {
    description = "${var.project} security group"
    vpc_id = aws_vpc.main.id

    dynamic "ingress" {
        for_each = var.sg_ports
        content {
          from_port   = ingress.value
          to_port     = ingress.value
          protocol    = "tcp"
          cidr_blocks = [var.vpc_cidr]
        }
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #Adding new key "Name" and its value "var.default_tags["Environment"]} Security Group" to default_tags, where var.default_tags["Environment"] takes value of Environment key from default.tags and put it in front of " Security Group".
    tags = merge(var.default_tags, { Name = "${var.default_tags["Environment"]} Security Group" }) 
  
}
