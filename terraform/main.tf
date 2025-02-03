provider "aws" {
  region = var.aws_region
}

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC1"
  }
}

# Create Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet1"
  }
}

# Create Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main_vpc.id

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App Ports (8080, 8081, 8082, 8083)
  ingress {
    from_port   = 8080
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #ICMP (Ping)
  ingress {
    from_port   = -1  
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2SecGroup"
  }
}

# Create ECR Repository for MySQL
resource "aws_ecr_repository" "mysql_repo" {
  name = "mysql-repo"
}

# Create ECR Repository for WebApp
resource "aws_ecr_repository" "webapp_repo" {
  name = "webapp-repo"
}

# Create EC2 Instance
resource "aws_instance" "app_instance" {
  ami                         = "ami-0241b1d769b029352" 
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my_key.key_name  
  subnet_id                   = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "MyAppServer"
  }
}

# Create an AWS Key Pair
resource "aws_key_pair" "my_key" {
  key_name   = "my_generated_key"
  public_key = file("${path.module}/my_generated_key.pub") 
}
