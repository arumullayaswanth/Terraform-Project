provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "one" {
  ami               = "ami-02f624c08a83ca16f"
  instance_type     = "t2.micro"
  key_name          = "my-Key pair"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  availability_zone = "us-east-1a"
  user_data         = <<EOF
#!/bin/bash
sudo -i
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "hai all this is my app created by terraform infrastructure by yaswanth server-1" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "two" {
  ami               = "ami-02f624c08a83ca16f"
  instance_type     = "t2.micro"
  key_name          = "my-Key pair"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  availability_zone = "us-east-1b"
  user_data         = <<EOF
#!/bin/bash
sudo -i
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "hai all this is my website created by terraform infrastructure by yaswanth server-2" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "three" {
  ami               = "ami-02f624c08a83ca16f"
  instance_type     = "t2.micro"
  key_name          = "my-Key pair"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  availability_zone = "us-east-1a"
  tags = {
    Name = "app-server-1"
  }
}

resource "aws_instance" "four" {
  ami               = "ami-02f624c08a83ca16f"
  instance_type     = "t2.micro"
  key_name          = "my-Key pair"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  availability_zone = "us-east-1b"
  tags = {
    Name = "app-server-2"
  }
}

resource "aws_security_group" "web_sg" {
  name = "web-sg"
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

resource "aws_s3_bucket" "example" {
  bucket = "yaswanth-terraform-bucket-123456"
  tags = {
    Name        = "MyS3Bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_user" "seven" {
  for_each = var.user_names
  name     = each.value
}

variable "user_names" {
  description = "List of IAM users to be created"
  type        = set(string)
  default     = ["user1", "user2", "user3", "user4"]
}

resource "aws_ebs_volume" "eight" {
  size              = 40
  availability_zone = "us-east-1b"
  encrypted         = true
  type              = "gp3"
  iops              = 3000
  throughput        = 125
  tags = {
    Name = "yaswanth-ebs"
  }
}
