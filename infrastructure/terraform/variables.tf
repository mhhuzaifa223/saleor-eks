# Project 01: Saleor on Amazon EKS
# File: variables.tf

# Prefix used in resource names.
variable "project_name" {
  description = "Name prefix for this project"
  type        = string
  default     = "project-01-saleor"
}

# The IP address range available inside our VPC.
variable "vpc_cidr" {
  description = "IP address range for the project network"
  type        = string
  default     = "10.0.0.0/16"
}

# Kubernetes version used by the EKS control plane.
variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.37"
}

# EC2 instance type used by the EKS worker-node group.
variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker node"
  type        = string
  default     = "t3.small"
}
# Public IPv4 CIDR ranges permitted to reach the EKS API.
variable "cluster_public_access_cidrs" {
  description = "IPv4 CIDR ranges allowed to access the EKS public API"
  type        = list(string)
  default     = ["5.14.142.147/32"]
}