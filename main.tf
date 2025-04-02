# Define the provider block, which specifies the cloud provider (AWS in this case) and the region.
provider "aws" {
  region = "us-east-1" # The AWS region where resources will be created.
}

# Create an EC2 instance resource named "one"
resource "aws_instance" "one" {
  ami               = "ami-02f624c08a83ca16f" # The Amazon Machine Image (AMI) ID for the EC2 instance.
  instance_type     = "t2.micro" # The type of EC2 instance (t2.micro is a free-tier eligible instance).
  key_name          = "my-Key pair" # The name of the SSH key pair used to access the instance.
  vpc_security_group_ids = [aws_security_group.web_sg.id] # Reference to the security group (defined below).
  availability_zone = "us-east-1a" # The specific Availability Zone to launch the instance in.
  
  # Provide user data to automatically configure the instance at launch.
  user_data         = <<EOF
#!/bin/bash
sudo -i
yum install -y httpd # Install Apache HTTP server.
systemctl start httpd # Start the Apache service.
systemctl enable httpd # Ensure Apache starts on boot.
echo "hai all this is my app created by terraform infrastructure by yaswanth server-1" > /var/www/html/index.html # Write a custom message to the index.html file.
EOF

  tags = {
    Name = "web-server-1" # Tag the EC2 instance with a name "web-server-1".
  }
}

# Create a second EC2 instance resource named "two"
resource "aws_instance" "two" {
  ami               = "ami-02f624c08a83ca16f" # AMI ID to use for this instance.
  instance_type     = "t2.micro" # EC2 instance type.
  key_name          = "my-Key pair" # The name of the key pair.
  vpc_security_group_ids = [aws_security_group.web_sg.id] # Reference to the security group.
  availability_zone = "us-east-1b" # Availability Zone for this instance.
  
  # Provide user data for automatic configuration.
  user_data         = <<EOF
#!/bin/bash
sudo -i
yum install -y httpd # Install Apache HTTP server.
systemctl start httpd # Start the Apache service.
systemctl enable httpd # Ensure Apache starts on boot.
echo "hai all this is my website created by terraform infrastructure by yaswanth server-2" > /var/www/html/index.html # Custom message for server-2.
EOF

  tags = {
    Name = "web-server-2" # Tag the EC2 instance with a name "web-server-2".
  }
}

# Create a third EC2 instance resource named "three"
resource "aws_instance" "three" {
  ami               = "ami-02f624c08a83ca16f" # AMI ID for the instance.
  instance_type     = "t2.micro" # Instance type.
  key_name          = "my-Key pair" # Name of the key pair.
  vpc_security_group_ids = [aws_security_group.web_sg.id] # Reference to the security group.
  availability_zone = "us-east-1a" # Availability Zone for the instance.
  tags = {
    Name = "app-server-1" # Tag this EC2 instance with the name "app-server-1".
  }
}

# Create a fourth EC2 instance resource named "four"
resource "aws_instance" "four" {
  ami               = "ami-02f624c08a83ca16f" # AMI ID for the instance.
  instance_type     = "t2.micro" # Instance type.
  key_name          = "my-Key pair" # Name of the key pair.
  vpc_security_group_ids = [aws_security_group.web_sg.id] # Reference to the security group.
  availability_zone = "us-east-1b" # Availability Zone for the instance.
  tags = {
    Name = "app-server-2" # Tag this EC2 instance with the name "app-server-2".
  }
}

# Create a security group resource "web_sg" that controls inbound and outbound traffic
resource "aws_security_group" "web_sg" {
  name = "web-sg" # Name of the security group.

  # Define an ingress rule for SSH (port 22) allowing access from anywhere (0.0.0.0/0).
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Define an ingress rule for HTTP (port 80) allowing access from anywhere (0.0.0.0/0).
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Define an egress rule allowing all outbound traffic (all ports and protocols).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" signifies all protocols.
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an S3 bucket named "yaswanth-terraform-bucket-123456"
resource "aws_s3_bucket" "example" {
  bucket = "yaswanth-terraform-bucket-123456" # The name of the S3 bucket (must be globally unique).

  tags = {
    Name        = "MyS3Bucket" # Tag the S3 bucket with a name.
    Environment = "Production" # Tag the bucket with environment "Production".
  }
}

# Enable versioning for the created S3 bucket
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id # Reference to the S3 bucket created above.

  versioning_configuration {
    status = "Enabled" # Enable versioning to allow multiple versions of objects in the bucket.
  }
}

# Create an IAM user for each name in the "user_names" variable
resource "aws_iam_user" "seven" {
  for_each = var.user_names # Loop over the list of user names defined in the variable.
  name     = each.value # The name of the IAM user.
}

# Define the variable "user_names" to store the list of IAM users
variable "user_names" {
  description = "List of IAM users to be created" # A description for the variable.
  type        = set(string) # The variable is a set of strings.
  default     = ["user1", "user2", "user3", "user4"] # Default set of user names.
}

# Create an EBS volume of size 40GB with specific configurations
resource "aws_ebs_volume" "eight" {
  size              = 40  # Size of the EBS volume in GB.
  availability_zone = "us-east-1b"  # The availability zone where the volume will be created.
  encrypted         = true  # Enable encryption for the volume.
  type              = "gp3"  # Type of the EBS volume (General Purpose SSD).
  iops              = 3000  # Input/output operations per second for the volume.
  throughput        = 125  # Throughput in MB/s for the volume.

  tags = {
    Name = "yaswanth-ebs"  # Tag the EBS volume with the name "yaswanth-ebs".
  }
}
