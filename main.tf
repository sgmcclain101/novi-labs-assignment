// main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "nginx" {
  name                 = "nginx-devops"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "nginx-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = true

  tags = {
    Project = "nginx-devops"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "nginx-sg"
  description = "Allow HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}

resource "aws_instance" "nginx_ec2" {
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type in us-east-1
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = false
  key_name                    = "your-key-name" # replace with your key name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 ${aws_ecr_repository.nginx.repository_url}:latest
              EOF

  tags = {
    Name = "nginx-ec2"
  }
}

resource "aws_lb" "nginx_alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [module.security_group.security_group_id]
}

resource "aws_lb_target_group" "nginx_tg" {
  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "nginx_target" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.nginx_ec2.id
  port             = 80
}
