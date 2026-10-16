# Project 01: Saleor on Amazon EKS

# Defines:
# 1. Availability Zone lookup
# 2. VPC, subnets, Internet Gateway and routing
# 3. IAM roles and policies
# 4. EKS Kubernetes control plane
# 5. EC2 worker-node group

# 1. LOOK UP AVAILABLE AVAILABILITY ZONES

data "aws_availability_zones" "available" {
  state = "available"
}


# 2. CREATE THE VPC
# A VPC is our logically isolated network in AWS.
# Its CIDR range is defined in variables.tf.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}


# 3. CREATE AN INTERNET GATEWAY
# Connects the VPC to the internet when routing and
# security rules permit traffic.

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}


# 4. CREATE TWO SUBNETS
# A subnet is a smaller IP range inside the VPC.
# Each subnet is placed in a different Availability Zone.
# count = 2 creates two subnets.
# count.index is 0 for the first and 1 for the second.
# cidrsubnet() calculates a distinct CIDR range for each.

resource "aws_subnet" "public" {
  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 1)

  availability_zone = data.aws_availability_zones.available.names[count.index]

  # Assign public IPv4 addresses to eligible instances
  # launched in these subnets.
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"

    # Helps AWS Load Balancer integrations discover public subnets.
    "kubernetes.io/role/elb" = "1"
  }
}


# 5. CREATE THE PUBLIC ROUTE TABLE
# A route table determines where network traffic goes.
# 0.0.0.0/0 represents all IPv4 destinations not matched by a more specific route.
# Send that traffic to the Internet Gateway.

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}


# 6. ASSOCIATE THE ROUTE TABLE WITH BOTH SUBNETS
# The association tells each subnet to use this route table.

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# 7. CREATE THE EKS CLUSTER IAM ROLE
# This role is for the EKS control plane, not your IAM user.
# The trust policy allows the EKS service to assume this role.

resource "aws_iam_role" "cluster" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "eks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}


# 8. ATTACH THE EKS CLUSTER POLICY
# Grants the EKS control plane permissions provided by this AWS-managed policy.

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# 9. CREATE THE EC2 WORKER-NODE IAM ROLE
# Worker nodes are EC2 instances that run our workloads.
# This trust policy lets EC2 assume the worker-node role.

resource "aws_iam_role" "nodes" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}


# 10. ATTACH WORKER-NODE POLICIES
# Worker nodes need permissions to register with EKS,
# support VPC networking, and pull container images from ECR.

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# 11. CREATE THE EKS CLUSTER
# EKS manages the Kubernetes control plane.
# Worker nodes are separate and defined in the next section.
# The cluster uses our two subnets and the cluster IAM role.

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-eks"
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = aws_subnet.public[*].id

    # Allow API access from inside the VPC.
    endpoint_private_access = true

    # Allow public API access only from the configured IP ranges.
    endpoint_public_access = true
    public_access_cidrs    = var.cluster_public_access_cidrs
  }

  # Attach the cluster permissions before creating EKS.
  depends_on = [
    aws_iam_role_policy_attachment.cluster
  ]

  tags = {
    Name = "${var.project_name}-eks"
  }
}


# 12. CREATE THE EKS WORKER-NODE GROUP
# A node group manages EC2 instances that run Kubernetes Pods.
# One t3.medium node is configured initially.
# The group can scale to two nodes, but autoscaling behaviour
# requires appropriate cluster autoscaling configuration.

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-workers"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = aws_subnet.public[*].id

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  # Ensure worker-node policies are attached first.
  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr
  ]

  tags = {
    Name = "${var.project_name}-worker"
  }
}
