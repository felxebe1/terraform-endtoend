## main.tf

# Define the provider
provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Generate a new private key
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create a key pair using the public key from the generated private key
resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/generated-key.pem"
  file_permission = "0400" # Only owner can read
}

# Create a security group allowing SSH and HTTP access
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow SSH and HTTP traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
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

# Define the EC2 instance
resource "aws_instance" "myfi" {
  ami           = "ami-04b70fa74e45c3917"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"
  security_groups = [aws_security_group.mysg.name]  # Use the name attribute of the security group
  key_name      = aws_key_pair.generated_key.key_name  # Reference the key pair

  tags = {
    Name = "Myterraform"
  }
}

# Output the instance's public IP
output "instance_ip" {
  value = aws_instance.myfi.public_ip
}
