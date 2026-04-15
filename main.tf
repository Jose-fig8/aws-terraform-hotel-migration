provider "aws" {
  region = "us-east-1"

}
# -------------------------
# VARIABLE: YOUR PUBLIC IP
# --------------------------
# Put your laptop/public IP in terraform.tfvars

variable "my_ip" {
  description = "Your public IP in CIDR format"
  type        = string

}

# --------------
# VPCs
# --------------

resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "Lab-VPC" }

}

resource "aws_vpc" "onprem_vpc" {
  cidr_block = "192.168.0.0/16"
  tags       = { Name = "OnPrem-VPC" }
}

# ---------------
# Subnets
# ---------------
resource "aws_subnet" "lab_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
  Name = "Lab-Subnet" }
}

resource "aws_subnet" "onprem_subnet" {
  vpc_id                  = aws_vpc.onprem_vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
  Name = "OnPrem-Subnet" }
}

# ------------------
# INTERNET GATEWAY
# ------------------

resource "aws_internet_gateway" "onprem_igw" {
  vpc_id = aws_vpc.onprem_vpc.id

  tags = {
  Name = "OnPrem-IGW" }

}

# --------------------------
# VPC Peering (VPN Simulation)
# --------------------------

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.lab_vpc.id
  peer_vpc_id = aws_vpc.onprem_vpc.id
  auto_accept = true

  tags = {
    Name = " Lab-OnPrem-Peer"
  }

}

# ---------------
# Route Tables
# ---------------

resource "aws_route_table" "lab_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Lab-Route-Table"
  }

}

resource "aws_route" "lab_to_onprem" {
  route_table_id            = aws_route_table.lab_rt.id
  destination_cidr_block    = "192.168.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}

resource "aws_route_table" "onprem_rt" {
  vpc_id = aws_vpc.onprem_vpc.id

}

resource "aws_route" "onprem_to_lab" {
  route_table_id            = aws_route_table.onprem_rt.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}

resource "aws_route_table_association" "lab_assoc" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_rt.id

}

resource "aws_route_table_association" "onprem_assoc" {
  subnet_id      = aws_subnet.onprem_subnet.id
  route_table_id = aws_route_table.onprem_rt.id

}

resource "aws_route" "onprem_to_internet" {
  route_table_id         = aws_route_table.onprem_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.onprem_igw.id

}
# ------------------
# Security Group
# ------------------

resource "aws_security_group" "lab_sg" {
  name        = "lab-sg"
  description = "Allow Traffic from OnPrem VPC"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "SSH from OnPrem VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]

  }

  ingress {
    description = "ICMP/Ping from OnPrem VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "onprem_sg" {
  name        = "onprem-sg"
  description = "Allow SSH from Laptop and traffic to Lab VPC"
  vpc_id      = aws_vpc.onprem_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    description = "ICMP/Ping from my laptop"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    description = "Allow traffic from Lab VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "OnPrem-SG"
  }
}

# ----------------
# EC2 Instances
# ----------------

resource "aws_instance" "printer" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = "lab-key"
  tags                   = { Name = "Printer-Server" }

}

resource "aws_instance" "keycard" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = "lab-key"
  tags                   = { Name = "Keycard-Server" }

}

resource "aws_instance" "music" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = "lab-key"
  tags                   = { Name = "Music-Server" }

}
resource "aws_instance" "hotel_client" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.onprem_subnet.id
  vpc_security_group_ids      = [aws_security_group.onprem_sg.id]
  key_name                    = "lab-key"
  associate_public_ip_address = true

  tags = { Name = "Hotel-Client" }

}

# -------------------
# OUTPUTS
# -------------------

output "hotel_client_public_ip" {
  value = aws_instance.hotel_client.public_ip

}
output "hotel_client_private_ip" {
  value = aws_instance.hotel_client.private_ip

}
output "printe_private_ip" {
  value = aws_instance.printer.private_ip

}
output "keycard_privte_ip" {
  value = aws_instance.keycard.private_ip

}
output "music_private_ip" {
  value = aws_instance.music.private_ip

}




