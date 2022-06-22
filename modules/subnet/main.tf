resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = var.myapp-vpc.id
  cidr_block = var.subent-cidr_block
  availability_zone = var.avail-zone
  tags = {
    "Name" = "${environment}-subnet"
  }
}

resource "aws_route_table" "myapp-rtb" {
  vpc_id = var.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    "Name" = "${environment}-rtb"
  }
  
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.myapp-vpc.id
  tags_all = {
    "Name" = "${environment}-igw"
  }
  
}

resource "aws_route_table_association" "a-rtb" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-rtb.id
  
}