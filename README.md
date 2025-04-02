# Terraform and Jenkins Setup Guide

## Step 1: Launch EC2 and Install Terraform
1. Launch an EC2 instance.
2. Connect to the EC2 instance via SSH.
3. Install Terraform on the EC2 instance.

## Step 2: Grant Permissions to Terraform
1. Navigate to **IAM (Identity and Access Management)**.
2. Go to **Users** → Click **Create User**.
3. Set **User Name** as `terraform`.
4. Click **Next** → **Set Permissions** → **Permission Options**.
5. Select **Attach Policies Directly** → Choose **Administrator Access**.
6. Click **Next** → **Create User**.
7. Open the **terraform user** profile.
8. Go to **Security Credentials** → **Access Key** → **Create Access Key**.
9. Select **Use Case** → **CLI**.
10. Confirm by selecting "I understand the recommendation and want to proceed".
11. Click **Next** → **Create Access Key**.
12. Download the **.csv file**.

## Step 3: Configure AWS CLI on EC2
1. Run the following command:
   ```sh
   aws configure
   ```
2. Provide the required values:
   ```sh
   aws_access_key_id = YOUR_ACCESS_KEY
   aws_secret_access_key = YOUR_SECRET_KEY
   region = us-east-1
   output = table
   ```
3. Verify configuration:
   ```sh
   aws configure list
   aws sts get-caller-identity
   ```

## Step 4: Install Terraform on EC2
1. Create a script:
   ```sh
   vim terraform.sh
   ```
2. Add the following content:
   ```sh
   # Step 1: Install Required Packages
   sudo yum install -y yum-utils shadow-utils

   # Step 2: Add the HashiCorp Repository
   sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

   # Step 3: Install Terraform
   sudo yum -y install terraform
   terraform -version
   ```
3. Run the script:
   ```sh
   sh terraform.sh
   ```

## Step 5: Install Jenkins on EC2
1. Create a script:
   ```sh
   vim Jenkins.sh
   ```
2. Add the following content:
   ```sh
   # Install required packages
   yum install git java-1.8.0-openjdk maven -y

   # Add Jenkins repository
   sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
   sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

   # Install Java and Jenkins
   sudo yum install java-17-amazon-corretto -y
   yum install jenkins -y
   update-alternatives --config java

   # Start Jenkins service
   systemctl start jenkins.service
   systemctl status jenkins.service
   ```
3. Run the script:
   ```sh
   sh Jenkins.sh
   ```

## Step 6: Retrieve Jenkins Initial Admin Password
```sh
cat /var/lib/jenkins/secrets/initialAdminPassword
```
Copy the password for the next step.

## Step 7: Access Jenkins UI
1. Copy the public IP address of your EC2 instance.
2. Open a browser and enter:
   ```
   http://<Public-IP>:8080
   ```
3. Paste the **initial admin password**.
4. Install **suggested plugins**.
5. Create the **first admin user**:
   - Username
   - Password
   - Full Name
   - Email
6. Click **Save and Continue** → **Save and Finish** → **Start using Jenkins**.

## Step 8: Configure Terraform Credentials in Jenkins
1. Open **Jenkins Dashboard** → **Manage Jenkins**.
2. Navigate to **Credentials** → **System** → **Global Credentials (unrestricted)**.
3. Click **Add Credentials**:
   - **Kind**: Select **Secret Text**
   - **Secret**: Enter your **AWS Access Key**
   - **ID**: `accesskey`
   - **Description**: Enter a meaningful description
4. Click **Save**.
5. Add another credential:
   - **Kind**: Select **Secret Text**
   - **Secret**: Enter your **AWS Secret Key**
   - **ID**: `secretkey`
   - **Description**: Enter a meaningful description
6. Click **Save**.

## Step 9: Create a Jenkins Pipeline Job for Terraform
1. Navigate to **Jenkins Dashboard** → **New Item**.
2. Enter **Name**: `terraform-project`.
3. Select **Pipeline** → Click **OK**.
4. Under **Pipeline Configuration**:
   - **This project is parameterized** → **Add Parameter** → **Choice Parameter**
   - **Name**: `action`
   - **Choices**: `apply` and `destroy`
5. Add the following pipeline script:
   ```groovy
   pipeline {
       agent any

       environment {
           AWS_ACCESS_KEY_ID     = credentials('accesskey')
           AWS_SECRET_ACCESS_KEY = credentials('secretkey')
       }
       
       stages {
           stage('checkout') {
               steps {
                   git 'https://github.com/arumullayaswanth/Terraform-Project.git'
               }
           }
           stage('init') {
               steps {
                   sh 'terraform init'
               }
           }
           stage('validate') {
               steps {
                   sh 'terraform validate'                
               }
           }
           stage('plan') {
               steps {
                   sh 'terraform plan'
               }
           }
           stage('action') {
               steps {
                   sh 'terraform $action --auto-approve'
               }
           }
       }
   }
   ```
6. Click **Save**.

## Step 10: Build with Parameters
1. Open **Jenkins Dashboard** → Select **terraform-project**.
2. Click **Build with Parameters**.
3. Choose **action** → Select `apply`.
4. Click **Build**.

## Step 11: Verify Terraform Deployment
1. SSH into your Terraform EC2 instance.
2. Run the following commands:
   ```sh
   cd /var/lib/jenkins/workspace/terraform-project
   ll
   ```
3. List Terraform state:
   ```sh
   terraform state list
   ```

