# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "novi-nginx-app"
environment  = "dev"

# Network Configuration
vpc_cidr               = "10.0.0.0/16"
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]

# ECS Configuration
fargate_cpu    = 256
fargate_memory = 512
app_count      = 2