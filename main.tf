provider "aws" {
    region = "ap-south-1"
    access_key = ""
    secret_key = "2"
}

variable vpc_cidr_block {}
variable subent_cidr_block {}
variable availe_zone {}
variable env_prefix {}
variable instance_type {}
variable my_ip {}
variable public-key-location {}

resource "aws_vpc" "myapp_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp_vpc.id
    cidr_block = var.subent_cidr_block
    availability_zone = var.availe_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
}

}

resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp_igw.id
    }
    tags = {
        Name = "${var.env_prefix}-route"
    }
}

resource "aws_internet_gateway" "myapp_igw" {
    vpc_id = aws_vpc.myapp_vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-sg" 
    }
}

data "aws_ami" "latest_amazon_linux_image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-992"]
    }
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest_amazon_linux_image.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.availe_zone
    associate_public_ip_address = true
    key_name = "keypair"
    tags = {
        Name: "${var.env_prefix}-server"
    }
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public-key-location)
}
