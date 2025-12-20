
data "aws_key_pair" "key" {
  key_name = "aitac-automation-uswest2-key"
}

data "aws_subnet" "subnet1_admin_public" {
  id = "subnet-0d558a5dfbd37497b"
}

data "aws_subnet" "subnet2_admin_private" {
  id = "subnet-020ea78b0ba860caa"
}

data "aws_subnet" "subnet3_class_public" {
  id = "subnet-0ae3b6f08fd718de3"
}

data "aws_subnet" "subnet4_class_private" {
  id = "subnet-0f9401b267ce31a48"
}

data "aws_security_group" "ext_sg" {
  id = "sg-02a96b522f9ae9994"
}

data "aws_security_group" "int_sg" {
  id = "sg-01ddc99b125f42caf"
}


resource "aws_instance" "nginx-proxy" {
  ami           = "ami-00902599b9670c948"
  instance_type = "t4g.medium"

  subnet_id              = data.aws_subnet.subnet1_admin_public.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [data.aws_security_group.ext_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "aitac-nginx"
    Role = "aitac-nginx"
  }
  
  credit_specification {
    cpu_credits = "standard"
  }
}

resource "aws_eip" "nginx_eip" {
  domain = "vpc"
  tags = {
    Name = "aitac-automation-nginx-eip"
  }
}

resource "aws_eip_association" "ec2_eip_assoc" {
  instance_id   = aws_instance.nginx-proxy.id
  allocation_id = aws_eip.nginx_eip.id
}

resource "aws_instance" "nat-tailscale" {
  ami           = "ami-00902599b9670c948"
  instance_type = "t4g.micro"

  subnet_id              = data.aws_subnet.subnet1_admin_public.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [data.aws_security_group.ext_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = "aitac-nat"
    Role = "aitac-nat"
  }
  credit_specification {
    cpu_credits = "standard"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "aitac-automation-nginx-eip"
  }
}

resource "aws_eip_association" "nat_eip_assoc" {
  instance_id   = aws_instance.nat-tailscale.id
  allocation_id = aws_eip.nat_eip.id
}

output "nginx_public_ip" {
  description = "Nginx Public IP address"
  value       = aws_eip.nginx_eip.public_ip
}

output "nat_public_ip" {
  description = "NAT Public IP address"
  value       = aws_eip.nat_eip.public_ip
}

resource "aws_instance" "k3s" {
  ami           = "ami-02a57838d76127b6b"
  instance_type = "t3a.large"

  subnet_id              = data.aws_subnet.subnet1_admin_public.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [data.aws_security_group.int_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name = "aitac-k3s"
    Role = "aitac-k3s"
  }

  credit_specification {
    cpu_credits = "standard"
  }
}

resource "aws_instance" "aap26" {
  ami           = "ami-0d7cefc82bd37fe4c"
  instance_type = "t3a.xlarge"

  subnet_id              = data.aws_subnet.subnet1_admin_public.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [data.aws_security_group.int_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
  }

  tags = {
    Name = "aitac-aap26"
    Role = "aitac-aap26"
  }

  credit_specification {
    cpu_credits = "standard"
  }
}

resource "aws_instance" "docker" {
  ami           = "ami-02a57838d76127b6b"
  instance_type = "t3a.large"

  subnet_id              = data.aws_subnet.subnet1_admin_public.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [data.aws_security_group.int_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name = "aitac-docker"
    Role = "aitac-docker"
  }

  credit_specification {
    cpu_credits = "standard"
  }
}
