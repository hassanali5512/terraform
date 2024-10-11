# Specify the provider and region
provider "aws" {
  region     = "eu-north-1"
  access_key = xyz
  secret_key = xyz
}

# Define a security group with ingress and egress rules
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Allow SSH, HTTP, Jenkins, and MongoDB traffic"

  # Ingress rules (allow incoming traffic)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP access from anywhere
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins access from anywhere
  }
ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Container access from anywhere
  }
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # MongoDB access from anywhere
  }

  # Egress rules (allow outgoing traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}

# Define an EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-08eb150f611ca277f" 
  instance_type = "t3.large"             
  key_name      = "mern_app"           

  # Root block device (volume)
  root_block_device {
    volume_size = 30  # Root volume size in GB
  }

  # Specify the user data file for instance initialization
  user_data = file("${path.module}/user_data.sh") 

  tags = {
    Name = "MyTerraformInstance"
  }

  # Associate the security group
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
}

# Output the public IP address of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
