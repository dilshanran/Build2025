terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Create EC2 instance
resource "aws_instance" "Jenkins-Server" {
  ami                    = "ami-0df8c184d5f6ae949"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraformjenkins.key_name
  vpc_security_group_ids = [aws_security_group.sg_jenkins.id]

  #Supply user data script for Jenkins install and bootstrap
  user_data = file("install-jenkins.sh")
  tags = {
    Name = "terraform-jenkins"
  }
}

# Generate private and public key pair using the TLS provider
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

#Generate public key pair
resource "aws_key_pair" "terraformjenkins" {
  key_name   = "terraformjenkins"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "terraformjenkins.pem"
}

#Create security group
resource "aws_security_group" "sg_jenkins" {
  name        = "sg_jenkins"
  description = "Allow SSH and port 8080 inbound traffic"
  vpc_id      = "vpc-07fa2ee0d82d82ccc"

  tags = {
    Name = "sg_jenkins"
  }

  #Security group ingress rule SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Security group ingress rule allow 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Security group egress rule to allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create S3 bucket for Jenkins artifacts
resource "aws_s3_bucket" "jenkins-bucket" {
  bucket = "terraform-jenkins1"
}

resource "aws_s3_bucket_public_access_block" "jenkins-bucket" {
  bucket = aws_s3_bucket.jenkins-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Output the public IP of the Jenkins instance

output "jenkins_instance_public_ip" {
  value = aws_instance.Jenkins-Server.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.jenkins-bucket.bucket
}
