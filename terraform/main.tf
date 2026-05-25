terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# ECR Repository to store Docker images
resource "aws_ecr_repository" "pipeline_demo" {
  name                 = "pipeline-demo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Security Group for EC2
resource "aws_security_group" "pipeline_demo_sg" {
  name        = "pipeline-demo-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# EC2 Instance
resource "aws_instance" "pipeline_demo" {
  ami                    = "ami-0f58b397bc5c1f2e8"  # Amazon Linux 2023 ap-south-1
  instance_type          = "t3.micro"               # free tier
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.pipeline_demo_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "pipeline-demo"
  }
}