## Originally main.tf file
## Renamed to the networking.tf file.
locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {}

resource "random_id" "random" {
  byte_length = 2
}

resource "aws_vpc" "mtc_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "mtc_vpc-${random_id.random.dec}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mtc_vpc.id
  tags = {
    Name = "mtc_igw-${random_id.random.dec}"
  }
}

resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "mtc_public"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_default_route_table" "mtc_private_rt" {
  default_route_table_id = aws_vpc.mtc_vpc.default_route_table_id

  tags = {
    Name = "mtc_private"
  }
}

resource "aws_subnet" "mtc_public_subnet" {
  count  = length(local.azs)
  vpc_id = aws_vpc.mtc_vpc.id
  # For public subnets, we will use just count.index for the netnum, that way the 
  # last network will be incremented by one.
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  # Will create the subnet in the first listed AZ.
  availability_zone = local.azs[count.index]

  tags = {
    Name = "mtc-public-${count.index + 1}"
  }
}

resource "aws_subnet" "mtc_private-subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index)
  map_public_ip_on_launch = false
  # Will create the subnet in the first listed AZ.
  availability_zone = local.azs[count.index]

  tags = {
    Name = "mtc-private-${count.index + 1}"
  }
}

## Connecting the AWS Subnets to their appropriate RTs.
resource "aws_route_table_association" "mtc_public_assoc" {
  count = length(local.azs)
  # Note the use of splat(*). it's saying is all of the public subnet set have been created. 
  # Put those in a list and then pull the index out of that list. Now that's going to work just the same as if we were to.
  # At Count Dot Index right here, 
  # subnet_id = aws_subnet.mtc_public_subnet.*.id[count.index]- alternatively we can also use
  subnet_id      = aws_subnet.mtc_public_subnet[count.index].id
  route_table_id = aws_route_table.mtc_public_rt.id

}

## We are not creating the private route table, because, the all private RTs are going to fallback to the
## default private RT, hence explicit association is not required.

# Create the base SG
resource "aws_security_group" "mtc_sg_pub" {
  name        = "public_sg"
  description = "Security Group for Publicly accessible Instances"
  vpc_id      = aws_vpc.mtc_vpc.id

  tags = {
    "Name" = "Public_Sg"
  }

}

# Create the rules for the SG Rule allowing all incoming
resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress" # 
  from_port         = 0         # starting port for port access
  to_port           = 65535     # Ending port for port access
  protocol          = "-1"      # Specifies any protocol.Includes UDP/TCP/ICMP
  cidr_blocks       = [var.access_ip]
  security_group_id = aws_security_group.mtc_sg_pub.id

}

# Create the rules for the SG Rule allowing all outgoing
resource "aws_security_group_rule" "egress_all" {
  type              = "egress" # 
  from_port         = 0        # starting port for port access
  to_port           = 65535    # Ending port for port access
  protocol          = "-1"     # Specifies any protocol.Includes UDP/TCP/ICMP
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mtc_sg_pub.id

}

# Create the base SG
resource "aws_security_group" "mtc_sg_priv" {
  name        = "private_sg"
  description = "Security Group for Publicly accessible Instances"
  vpc_id      = aws_vpc.mtc_vpc.id

  tags = {
    "Name" = "Private_Sg"
  }

}
