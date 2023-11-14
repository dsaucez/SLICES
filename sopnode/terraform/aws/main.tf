# Author: Surya Kumar Kunderu
# Project: Slices RI
# Version: 1.0
# License: None - Opensource

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

locals {
#   vpc_id  = "vpc-055d42e2066fc756f"
#   subnet_id = "subnet-045dc13d9dafef815"
    ssh_user  = "ubuntu"
    key_name  = "slices"
    private_key_path  = "~/slices.pem"
}

provider "aws" {
    region  = "us-east-1"
}

resource "aws_vpc" "slices_vpc" {
  cidr_block  = "10.0.0.0/16"

  tags = {
    Name = "Slices VPC"
  }
}

#Public Subnet with Default Route to Internet Gateway
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.slices_vpc.id
    cidr_block = "10.0.0.0/24"

    tags = {
        Name = "Public Subnet"
    }
}

#Private Subnet with Default Route to NAT Gateway
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.slices_vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "Private Subnet"
    }
}

#Internet Gateway for VPC (to be used by public subnet)
resource "aws_internet_gateway" "slices_igw" {
    vpc_id = aws_vpc.slices_vpc.id

    tags = {
        Name = "Slices IGW"
    }
}

#Elastic IP for NAT Gateway (to be used by private subnet)
resource "aws_eip" "nat_eip" {
    vpc = true
    depends_on = [aws_internet_gateway.slices_igw]

    tags = {
        Name = "NAT Gateway EIP"
    }
}

#NAT Gateway for VPC
resource "aws_nat_gateway" "slices_nat_gw" {
    allocation_id   = aws_eip.nat_eip.id
    subnet_id       = aws_subnet.public.id

    tags = {
        Name = "Slices NAT GW"
    }
}

#Route Table for Public Subnet
resource "aws_route_table" "public_route_tab" {
    vpc_id = aws_vpc.slices_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.slices_igw.id
    }
    
    tags = {
        Name = "Public Route Table"
    }
}

#Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public_route_tab_assoc" {
    subnet_id   = aws_subnet.public.id
    route_table_id = aws_route_table.public_route_tab.id
}

#Route Table for Private Subnet
resource "aws_route_table" "private_route_tab" {
    vpc_id = aws_vpc.slices_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.slices_nat_gw.id
    }
    
    tags = {
        Name = "Private Route Table"
    }
}

#Association between Private Subnet and Private Route Table
resource "aws_route_table_association" "private_route_tab_assoc" {
    subnet_id   = aws_subnet.private.id
    route_table_id = aws_route_table.private_route_tab.id
}

resource "aws_security_group" "slices_sg" {
  name = "blueprint_deploy"
  vpc_id = aws_vpc.slices_vpc.id

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
   from_port    = 0
   to_port      = 0
   protocol     = "-1"
   cidr_blocks  = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "control" {
  ami                         = "ami-0feba2720136a0493"
  subnet_id                   = aws_subnet.public.id
  instance_type               = "m7g.xlarge"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.slices_sg.id]
  key_name                    = local.key_name

  tags = {
    Name = var.instance_control  }
}

#IP of aws instance copied to a file instance_control_ip.txt in local system
resource "local_file" "ip" {
    content  = aws_instance.control.public_ip
    filename = "instance_control_public_ip.txt"
}

resource "aws_instance" "master" {
  ami           = "ami-0feba2720136a0493"
  subnet_id     = aws_subnet.private.id
  instance_type = "m7g.xlarge"
  security_groups             = [aws_security_group.slices_sg.id]
  key_name                    = local.key_name

  tags = {
    Name = var.instance_master  }
}

resource "aws_instance" "worker1" {
  ami                         = "ami-0feba2720136a0493"
  subnet_id                     = aws_subnet.private.id
  instance_type = "m7g.xlarge"
  security_groups             = [aws_security_group.slices_sg.id]
  key_name                    = local.key_name

  tags = {
    Name = var.instance_worker1
  }
}

resource "aws_instance" "worker2" {
  ami                         = "ami-0feba2720136a0493"
  subnet_id                     = aws_subnet.private.id
  instance_type = "m7g.xlarge"
  security_groups             = [aws_security_group.slices_sg.id]
  key_name                    = local.key_name

  tags = {
    Name = var.instance_worker2
  }
}

resource "aws_instance" "openvpn-1" {
  ami                         = "ami-0feba2720136a0493"
  subnet_id                     = aws_subnet.private.id
  instance_type = "m7g.xlarge"
  security_groups             = [aws_security_group.slices_sg.id]
  key_name                    = local.key_name

  tags = {
    Name = var.instance_openvpn
  }
}

#Connecting to the Ansible control node using SSH connection
resource "null_resource" "downloadslicesgitrepo" {
  depends_on  = [aws_instance.control]
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'", "sudo apt update",
	    "sudo git clone https://github.com/dsaucez/SLICES"]

  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.control.public_ip
    }
  }
}

#Connecting to the Ansible control node using SSH connection
resource "null_resource" "copycontrolip" {
  depends_on  = [aws_instance.control]
  #copying the ip.txt file to the Ansible control node from local system 
  provisioner "file" {
    source      = "instance_control_public_ip.txt"
    destination = "instance_control_public_ip.txt"

  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.control.public_ip
    }
  }
}

#Connecting to the Ansible control node using SSH connection
resource "null_resource" "copysshkey" {
  depends_on  = [aws_instance.control]
  #copying the ip.txt file to the Ansible control node from local system 
  provisioner "file" {
    source      = local.private_key_path
    destination = "slices.pem"

  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.control.public_ip
    }
  }
}

#Connecting to the Ansible control node using SSH connection
resource "null_resource" "chmodsshkey" {
  depends_on  = [aws_instance.control]
  provisioner "remote-exec" {
    inline = ["chmod 400 slices.pem"]

  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.control.public_ip
    }
  }
}

#Connecting to the Ansible control node using SSH connection
resource "null_resource" "installdocker" {
  depends_on  = [aws_instance.control]
  provisioner "remote-exec" {
    inline = ["sudo apt install docker.io"]

  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.control.public_ip
    }
  }
}
