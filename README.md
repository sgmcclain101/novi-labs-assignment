# Novi Labs DevOps Assignment

This project deploys an nginx container on AWS using Terraform and GitHub Actions, meeting the requirements of the DevOps take-home assignment.

## Architecture Overview

The solution implements a production-ready, scalable architecture with the following components:

### Network Architecture
- **VPC**: Custom VPC with DNS support enabled
- **Public Subnets**: 2 public subnets across different AZs for high availability
- **Private Subnets**: 2 private subnets for application containers
- **Internet Gateway**: Enables internet access for public subnets
- **NAT Gateways**: Enable outbound internet access for private subnets
- **Route Tables**: Properly configured routing for public and private subnets

### Application Architecture
- **ECS Fargate**: Serverless container orchestration
- **Application Load Balancer**: Public-facing ALB in public subnets
- **Target Groups**: Health checking and load balancing
- **Security Groups**: Least-privilege access control
- **CloudWatch Logs**: Centralized logging

### Security Features
- Containers run in private subnets (no direct internet access)
- Security groups with minimal required access
- IAM roles with least privilege principles
- ALB provides single point of entry

## Prerequisites

1. **AWS Account**: Free tier eligible
2. **GitHub Repository**: For hosting the code
3. **AWS CLI**: Configured with appropriate credentials
4. **Terraform**: Version 1.5.7 or later

## Setup Instructions

### 1. Create S3 Bucket for Terraform State

```bash
# Create S3 bucket for Terraform state (replace with unique name)
aws s3 mb s3://novi-labs-terraform-state-bucket --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket novi-labs-terraform-state-bucket \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking (optional but recommended)
aws dynamodb create-table \
    --table-name novi-labs-terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-east-1
```

### 2. Configure GitHub Secrets

Add these secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### 3. Update Backend Configuration

Edit `main.tf` to use your unique S3 bucket name:

```hcl
backend "s3" {
  bucket = "your-unique-terraform-state-bucket"
  key    = "nginx-app/terraform.tfstate"
  region = "us-east-1"
}
```

### 4. Deploy Infrastructure

#### Option A: Using GitHub Actions (Recommended)

1. Push code to `main` branch
2. GitHub Actions will automatically:
   - Run `terraform plan` on PRs
   - Run `terraform apply