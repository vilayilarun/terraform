resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = var.myapp-vpc_id

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
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.server-key.key_name
  user_data = file("entrypoint.sh")
  tags = {
    Name = "${var.environment}-server"
  }
  # provisioners
connection {
  type = "ssh"
  host = self.public_ip
  user = "ec2-user"
  private_key = file(var.private-key-location)
}
provisioner "file" {
  source = "entrypoint.sh"
  destination = "/home/ec2-user/entrypoint.sh"

}
provisioner "remote-exec" {
  script = file("entrypoint.sh")

}
provisioner "remote-exec" {
  inline = [
    "yum upadate",
    "dnf install docker"
  ]

}
}