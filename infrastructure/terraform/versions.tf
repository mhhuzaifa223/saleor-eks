# Project 01: Saleor on Amazon EKS
# File: versions.tf

# Require Terraform 1.5.0 or newer.
terraform {
  required_version = ">= 1.5.0"

  # Providers allow Terraform to manage external platforms.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
