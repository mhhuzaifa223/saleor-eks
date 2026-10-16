# Project 01: Saleor on Amazon EKS
# File: outputs.tf

# The name of our EKS cluster.
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

# The URL of the Kubernetes API server.
output "cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API"
  value       = aws_eks_cluster.main.endpoint
}

# The ID of our VPC.
output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

# The IDs of both public subnets.
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# The name of the managed worker-node group.
output "node_group_name" {
  description = "Name of the EKS managed node group"
  value       = aws_eks_node_group.main.node_group_name
}
