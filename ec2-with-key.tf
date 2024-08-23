provider "aws" {
  region = "ap-south-1"  # Replace with your preferred region
}
 
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
} 
 
resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/my-key-pair.pem"
}
 
resource "aws_key_pair" "example" {
  key_name   = "my-key-pair"
  public_key = tls_private_key.example.public_key_openssh
}
 
resource "aws_security_group" "example" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-12345678"  # Replace with your VPC ID
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_instance" "example" {
  ami           = "ami-0abcdef1234567890"  # Replace with your preferred AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name
  security_groups = [aws_security_group.example.name]
 
  tags = {
    Name = "example-instance"
  }
}
 
output "private_key_path" {
  value = local_file.private_key.filename
}
 
output "instance_id" {
  value = aws_instance.example.id
}
 
output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
