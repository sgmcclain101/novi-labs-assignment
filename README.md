# Novi Labs DevOps Take-Home Assignment

This project provisions AWS infrastructure using Terraform and deploys a Dockerized NGINX container via ECS Fargate with CI/CD powered by GitHub Actions.

## Architecture
- **VPC** with public/private subnets
- **ALB** routes traffic to ECS Fargate
- **ECR** stores custom nginx image
- **GitHub Actions** deploys infra and image

## How to Use
1. **Fork and clone this repo**
2. **Add GitHub Secrets**:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. **Push to `main` branch** – triggers:
   - Terraform infra deployment
   - Docker image build & push to ECR
   - ECS service update with new image

## Files
- `main.tf` – all Terraform resources
- `Dockerfile` – nginx image customization
- `html/index.html` – welcome page
- `.github/workflows/deploy.yml` – CI/CD pipeline

## Demo Expectations
Be ready to:
- Show GitHub pipeline
- Show AWS Console: VPC, ECS, ALB
- Browse to ALB DNS and see nginx page

---

Contact: [mcclain.sam@gmail.com](mailto:mcclain.sam@gmail.com)