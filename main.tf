
provider "aws" {
region = "us-east-1"
}

resource "aws_instance" "one" {
  ami             = "ami-02f624c08a83ca16f"
  instance_type   = "t2.micro"
  key_name        = "my-Key pair"
  vpc_security_group_ids = [aws_security_group.five.id]
  availability_zone = "us-east-1a"
  user_data       = <<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
chkconfig httpd on
echo "hai all this is my app created by terraform infrastructurte by yaswanth server-1" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "two" {
  ami             = "ami-02f624c08a83ca16f"
  instance_type   = "t2.micro"
  key_name        = "my-Key pair"
  vpc_security_group_ids = [aws_security_group.five.id]
  availability_zone = "us-east-lb"
  user_data       = <<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
chkconfig httpd on
echo "hai all this is my website created by terraform infrastructurte by yaswanth server-2" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "three" {
  ami             = "ami-02f624c08a83ca16f"
  instance_type   = "t2.micro"
  key_name        = "my-Key pair"
  vpc_security_group_ids = [aws_security_group.five.id]
  availability_zone = "us-east-1a"
  tags = {
    Name = "app-server-1"
  }
}

resource "aws_instance" "four" {
  ami             = "ami-02f624c08a83ca16f"
  instance_type   = "t2.micro"
  key_name        = "my-Key pair"
  vpc_security_group_ids = [aws_security_group.five.id]
  availability_zone = "us-east-1b"
  tags = {
    Name = "app-server-2"
  }
}

resource "aws_security_group" "five" {
  name = "elb-sg"
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

# Create an S3 Bucket with Tags
resource "aws_s3_bucket" "example" {
  bucket = "yaswanth523192"  # Must be globally unique

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Production"
  }
}

# Enable Versioning on the S3 Bucket
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}
# Create an IAM user with additional configurations
resource "aws_iam_user" "seven" {
for_each = var.user_names
name = each.value
}

variable "user_names" {
description = "*"
type = set(string)
default = ["user1", "user2", "user3", "user4"]
}

# Creates an EBS volume with encryption enabled
resource "aws_ebs_volume" "eight" {
  size              = 20  
  availability_zone = "us-east-1b"  
  encrypted         = true  
  type              = "gp3"  
  iops              = 3000  
  throughput        = 125  

  tags = {
    Name = "yaswanth-ebs"  
  }
}

