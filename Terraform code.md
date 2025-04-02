# Terraform AWS Deployment - Step-by-Step Guide

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- AWS CLI ([Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html))
- An AWS account with proper permissions

## Step 1: Configure AWS Credentials

Run the following command to configure your AWS CLI with access credentials:

```sh
aws configure
```

You will be prompted to enter:

- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region name** (e.g., `us-east-1`)
- **Default output format** ( table)

## Provider Configuration
```hcl
# Define the provider block, which specifies the cloud provider (AWS in this case) and the region.
provider "aws" {
  region = "us-east-1" # The AWS region where resources will be created.
}
```

## EC2 Instances

### Web Server 1
```hcl
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
```

### Web Server 2
```hcl
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
```

### App Servers
```hcl
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
```

## Security Group
```hcl
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
```

## S3 Bucket
```hcl
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
```

## IAM Users
```hcl
# Create an IAM user for each name in the "user_names" variable
resource "aws_iam_user" "seven" {
  for_each = var.user_names # Loop over the list of user names defined in the variable.
  name     = each.value # The name of the IAM user.
}

# Attach the AdministratorAccess policy to each IAM user
resource "aws_iam_user_policy_attachment" "admin_access" {
  for_each = var.user_names
  user     = aws_iam_user.seven[each.key].name # Attach the policy to each user.
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # The ARN for the AdministratorAccess policy.
}

# Define the variable "user_names" to store the list of IAM users
variable "user_names" {
  description = "List of IAM users to be created" # A description for the variable.
  type        = set(string) # The variable is a set of strings.
  default     = ["user1", "user2", "user3", "user4"] # Default set of user names.
}

```

## EBS Volume
```hcl
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
```


# Terraform AWS Infrastructure Setup

```hcl
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
```



## Step 1: Initialize Terraform
Run the following command in the project directory to initialize Terraform and download provider plugins:
```sh
terraform init
```

## Step 2: Format Terraform Code
Ensure your Terraform configuration files are properly formatted:
```sh
terraform fmt
```

## Step 3: Validate Configuration
Check if the Terraform configuration files are correctly formatted and error-free:
```sh
terraform validate
```

## Step 4: Plan the Deployment
Generate and review an execution plan before applying changes:
```sh
terraform plan
```

## Step 5: Apply the Configuration
Deploy the resources to AWS:
```sh
terraform apply -auto-approve
```

## Step 6: Verify the Deployment
Check the deployed AWS resources through the AWS console or use:
```sh
aws ec2 describe-instances
aws s3 ls
```

## Step 7: Destroy the Infrastructure (If Needed)
To remove all deployed resources, run:
```sh
terraform destroy -auto-approve
```


## Additional Notes

- Ensure your AWS IAM role has the necessary permissions to create EC2, S3, IAM, and other resources.
- Use `terraform fmt` to format the configuration files for better readability.
- Use `terraform output` to view resource outputs if defined in your Terraform script.

---

🚀 Now you have a fully automated AWS infrastructure using Terraform! 🎉





