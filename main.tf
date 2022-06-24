provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    "Name" = "${environment}-vpc "
  }
  
}

module "myapp-subnet" {
  source = "./modules/subnet"
  myapp-vpc = aws_vpc.myapp-vpc.id
  subnet-cidr-block = var.subnet-cidr-block
  environment = var.environment
  avail-zone = var.avail-zone
}

module "webserver" {
  source = "./modules/webserver"
  myapp-vpc_id = aws_vpc.myapp-vpc.id
  myip = var.myip
  environment = var.environment
  pub-key-location = var.pub-key-location
  avail-zone = var.avail-zone
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id
  private-key-location = var.private-key-location
  
}