resource "aws_vpc" "vpc" {
  cidr_block           = "10.33.0.0/16"
  tags = {
    Name = "aitac-automation-vpc"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.33.11.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "aitac-automation-subnet1-admin-public"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.33.22.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "aitac-automation-subnet2-admin-private"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.33.33.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "aitac-automation-subnet3-class-public"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.33.44.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "aitac-automation-subnet4-class-private"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "aitac-automation-igw"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "aitac-automation-rtb"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_route_table_association" "rt_assoc_subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "rt_assoc_subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "rt_assoc_subnet3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "rt_assoc_subnet4" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_security_group" "int_sg" {
  name   = "aitac-automation-internal-sg"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "aitac-automation-internal-sg"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_internal_eng" {
  security_group_id = aws_security_group.int_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4_internal_ing" {
  security_group_id = aws_security_group.int_sg.id
  cidr_ipv4         = "10.33.0.0/16"
  ip_protocol       = "-1"
}


resource "aws_security_group" "ext_sg" {
  name   = "aitac-automation-external-sg"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "aitac-automation-external-sg"
    Role = "aitac-automation-foundation"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_external_eng" {
  security_group_id = aws_security_group.ext_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_external_ing" {
  security_group_id = aws_security_group.ext_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4_external_ing" {
  security_group_id = aws_security_group.ext_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4_external_ing" {
  security_group_id = aws_security_group.ext_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_8xxx_ipv4_external_ing" {
  security_group_id = aws_security_group.ext_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8000
  to_port           = 8888
}
