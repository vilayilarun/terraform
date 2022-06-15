provider "aws" {
  region = "ap-south-1"
}

variable vpc-cidr-block {}
variable subnet-cidr-block {}
variable environment {}
variable avail-zone {}

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