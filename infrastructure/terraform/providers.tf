# Project 01: Saleor on Amazon EKS
# File: providers.tf

# Deploy resources into the Northern Virginia AWS Region.
# Region code us-east-1 means US East (N. Virginia).

provider "aws" {
  region = "us-east-1"

  # Apply these default tags to supported resources.
  default_tags {
    tags = {
      Project     = "project-01-saleor"
      Environment = "development"
      ManagedBy   = "Terraform"
    }
  }
}
