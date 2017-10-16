provider "aws" {}

variable "stack" {
  default = "dev1"
}

resource "aws_vpc" "dev" {
    cidr_block = "10.44.0.0/16"
    enable_dns_support = false
    tags {
      Name = "main"
      Stack = "${var.stack}"
    }
}
resource "aws_default_route_table" "dev_default" {
  default_route_table_id = "${aws_vpc.dev.default_route_table_id}"

  tags {
    Name = "Default ${var.stack} route table"
    Stack = "${var.stack}"
  }
}
resource "aws_route_table" "dev_internet" {
  vpc_id = "${aws_vpc.dev.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.dev.id}"
  }

  tags {
    Name = "${var.stack} internet route table"
    Stack = "${var.stack}"
  }
}
resource "aws_route_table" "dev_nat" {
  vpc_id = "${aws_vpc.dev.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.dev.id}"
  }

  tags {
    Name = "${var.stack} to nat route table"
    Stack = "${var.stack}"
  }
}
resource "aws_route_table_association" "dev_internet" {
  subnet_id      = "${aws_subnet.dev_2a_public.id}"
  route_table_id = "${aws_route_table.dev_internet.id}"
}
resource "aws_route_table_association" "dev_nat_2a" {
  subnet_id      = "${aws_subnet.dev_2a_private.id}"
  route_table_id = "${aws_route_table.dev_nat.id}"
}
resource "aws_route_table_association" "dev_nat_2b" {
  subnet_id      = "${aws_subnet.dev_2b_private.id}"
  route_table_id = "${aws_route_table.dev_nat.id}"
}
resource "aws_route_table_association" "dev_nat_2c" {
  subnet_id      = "${aws_subnet.dev_2c_private.id}"
  route_table_id = "${aws_route_table.dev_nat.id}"
}
resource "aws_default_network_acl" "dev" {
  default_network_acl_id = "${aws_vpc.dev.default_network_acl_id}"
  subnet_ids         = [
    "${aws_subnet.dev_2a_public.id}",
    "${aws_subnet.dev_2a_private.id}",
    "${aws_subnet.dev_2b_private.id}",
    "${aws_subnet.dev_2c_private.id}"
  ]

  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 100
  #   action     = "allow"
  #   cidr_block = "0.0.0.0/0"
  #   from_port  = 22
  #   to_port    = 22
  # }
  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 200
  #   action     = "allow"
  #   cidr_block = "0.0.0.0/0"
  #   from_port  = 49152
  #   to_port    = 65535
  # }
  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 100
  #   action     = "allow"
  #   cidr_block = "0.0.0.0/0"
  #   from_port  = 443
  #   to_port    = 443
  # }
  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 200
  #   action     = "allow"
  #   cidr_block = "0.0.0.0/0"
  #   from_port  = 49152
  #   to_port    = 65535
  # }
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags {
    Name = "main"
    Stack = "${var.stack}"
  }
}
resource "aws_subnet" "dev_2a_public" {
  vpc_id     = "${aws_vpc.dev.id}"
  cidr_block = "10.44.11.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.stack}-us-west-2a-public"
    Access = "public"
    Stack = "${var.stack}"
  }
}
resource "aws_subnet" "dev_2a_private" {
  vpc_id     = "${aws_vpc.dev.id}"
  cidr_block = "10.44.10.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.stack}-us-west-2a-private"
    Access = "private"
    Stack = "${var.stack}"
  }
}
resource "aws_subnet" "dev_2b_private" {
  vpc_id     = "${aws_vpc.dev.id}"
  cidr_block = "10.44.20.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.stack}-us-west-2b-private"
    Access = "private"
    Stack = "${var.stack}"
  }
}
resource "aws_subnet" "dev_2c_private" {
  vpc_id     = "${aws_vpc.dev.id}"
  cidr_block = "10.44.30.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = false
  tags {
    Name = "${var.stack}-us-west-2c-private"
    Access = "private"
    Stack = "${var.stack}"
  }
}
resource "aws_eip" "dev_inbound" {
  vpc      = true
}
resource "aws_eip" "dev_outbound" {
  vpc      = true
}
resource "aws_default_security_group" "dev_default" {
  vpc_id = "${aws_vpc.dev.id}"

  tags {
    Name = "${var.stack}-default"
    Stack = "${var.stack}"
  }
}
resource "aws_security_group" "ssh_in" {
  name        = "${var.stack}-ssh-in"
  description = "Allow inbound SSH traffic"
  vpc_id = "${aws_vpc.dev.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.stack}-ssh-in"
    Stack = "${var.stack}"
  }
}
resource "aws_security_group" "ssh_out" {
  name        = "${var.stack}-ssh-out"
  description = "Allow outbound SSH traffic"
  vpc_id = "${aws_vpc.dev.id}"

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.stack}-ssh-out"
    Stack = "${var.stack}"
  }
}
resource "aws_security_group" "web_in" {
  name        = "${var.stack}-web-in"
  description = "Allow inbound HTTPS traffic"
  vpc_id = "${aws_vpc.dev.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.stack}-web-in"
    Stack = "${var.stack}"
  }
}
resource "aws_security_group" "dns_out" {
  name        = "${var.stack}-dns-out"
  description = "Allow DNS traffic out"
  vpc_id = "${aws_vpc.dev.id}"

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.stack}-dns-out"
    Stack = "${var.stack}"
  }
}
resource "aws_security_group" "web_out" {
  name        = "${var.stack}-web-out"
  description = "Allow HTTPS traffic out"
  vpc_id = "${aws_vpc.dev.id}"

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.stack}-web-out"
    Stack = "${var.stack}"
  }
}
resource "aws_security_group" "all_out" {
  name        = "${var.stack}-all-out"
  description = "Allow ALL traffic out"
  vpc_id = "${aws_vpc.dev.id}"

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.stack}-web-out"
    Stack = "${var.stack}"
  }
}
resource "aws_nat_gateway" "dev" {
  depends_on = [
    "aws_internet_gateway.dev"
  ]
  allocation_id        = "${aws_eip.dev_outbound.id}"
  subnet_id            = "${aws_subnet.dev_2a_public.id}"

  tags {
    Name = "${var.stack}-us-west-2a"
    Stack = "${var.stack}"
  }
}
resource "aws_internet_gateway" "dev" {
  vpc_id = "${aws_vpc.dev.id}"

  tags {
    Name = "dev-internet"
    Stack = "${var.stack}"
  }
}


# resource "aws_network_interface_sg_attachment" "nat_sg_attachment_web_out" {
#   security_group_id    = "${aws_security_group.web_out.id}"
#   network_interface_id = "${aws_nat_gateway.dev.network_interface_id}"
# }

# resource "aws_network_interface" "dev_nat" {
#   subnet_id       = "${aws_subnet.dev_2a.id}"
#   private_ips = [
#     "10.44.10.143"
#   ]
#   security_groups = [
#     "${aws_security_group.web_out.id}"
#   ]
#   tags {
#     Name = "dev-nat-gateway"
#     Stack = "${var.stack}"
#   }
# }
# resource "aws_flow_log" "nat" {
#   log_group_name = "${aws_cloudwatch_log_group.test_log_group.name}"
#   iam_role_arn   = "${aws_iam_role.test_role.arn}"
#   vpc_id         = "${aws_vpc.default.id}"
#   traffic_type   = "ALL"
# }


# resource "aws_alb" "dev" {
#   name            = "dev-alb"
#   internal        = false
#   security_groups = [
#     "${aws_security_group.dev_web.id}"
#   ]
#   subnets         = [
#     "${aws_subnet.dev_2a.id}",
#     "${aws_subnet.dev_2b.id}",
#     "${aws_subnet.dev_2c.id}"
#   ]
#   # enable_deletion_protection = true
#
#   # access_logs {
#   #   bucket = "${aws_s3_bucket.alb_logs.bucket}"
#   #   prefix = "test-alb"
#   # }
#
#   tags {
#     Name = "dev-alb"
#     Stack = "${var.stack}"
#   }
# }
