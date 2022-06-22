output "ec2-public-ip" {
  value = aws_instance.myapp-server.public_ip
  
}
