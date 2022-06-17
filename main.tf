provider "aws" {
  region = "ap-south-1"
}

variable vpc-cidr-block {}
variable subnet-cidr-block {}
variable environment {}
variable avail-zone {}
variable myip {}
variable instance_type {}
variable pub-key-location {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    "Name" = "${environment}-vpc "
  }
  
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subent-cidr_block
  availability_zone = var.avail-zone
  tags = {
    "Name" = "${environment}-subnet"
  }
}

resource "aws_route_table" "myapp-rtb" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    "Name" = "${environment}-rtb"
  }
  
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags_all = {
    "Name" = "${environment}-igw"
  }
  
}

resource "aws_route_table_association" "a-rtb" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-rtb.id
  
}

resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.myip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.myip]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  
  tags = {
    Name = "${var.environment}-sg"
  }
}

data "aws_ami" "Linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter = {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
}
resource "aws_key_pair" "server-key" {
  key_name = "server-key"
  public_key = file(var.pub-key-location)
  
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.Linux-image.id
  availability_zone = var.avail-zone
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.server-key.key_name
  user_data = file("entrypoint.sh")
  tags = {
    Name = "${var.environment}-server"
  }
}

output "ec2-public-ip" {
  value = aws_instance.myapp-server.public_ip
  
}