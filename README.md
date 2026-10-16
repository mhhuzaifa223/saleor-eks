# Saleor on Amazon EKS

This project is part of my DevOps learning journey. I worked on deploying Saleor, an open-source e-commerce platform, on Amazon EKS and managing the infrastructure and application configuration with tools commonly used in DevOps.

The goal was not just to get the application running, but also to understand how the different parts fit together and how to make the setup easier to maintain.

## What I worked on

- Set up Kubernetes resources for Saleor, including the API, dashboard, and background worker.
- Used Amazon EKS to run the application.
- Configured an AWS Application Load Balancer to handle incoming traffic.
- Connected the application to Amazon RDS for PostgreSQL.
- Used Helm to organize and manage Kubernetes configurations.
- Used Terraform to define infrastructure as code.
- Configured custom subdomains and HTTPS for the API and dashboard.
- Added a GitHub Actions workflow to check the Helm chart whenever code is pushed or a pull request is opened.

## How it works

Users access the Saleor dashboard and API through their custom domains. Traffic is routed through the AWS load balancer to the services running in EKS.

The Saleor API uses PostgreSQL on Amazon RDS for persistent data storage. Kubernetes manages the application workloads, while Helm helps keep the deployment configuration organized.

## Tools and technologies

- AWS: EKS, EC2, Application Load Balancer, RDS, ACM
- Kubernetes
- Helm
- Terraform
- Docker
- Git and GitHub
- GitHub Actions
- PostgreSQL
- Linux

## CI workflow

I added a basic GitHub Actions pipeline to catch configuration issues early. It checks out the repository, sets up Helm, lints the Saleor Helm chart, and renders the Kubernetes templates.

The workflow is currently focused on validation. It does not automatically deploy changes to the EKS cluster.

## Security considerations

During the project, I reviewed database accessibility, storage encryption, security group rules, and how application credentials are supplied to Kubernetes.

The RDS instance is configured as private and has storage encryption enabled. Sensitive files, database backups, private keys, and Terraform state are excluded through `.gitignore`.

These checks are part of my effort to build safer infrastructure habits. The configuration still needs a complete production security review before it could be considered production-ready.

## What I learned

This project helped me get more practical experience with Kubernetes deployments, Helm templates, AWS networking, database connectivity, HTTPS configuration, and CI validation.

I also learned that getting an application running is only one part of the work. Troubleshooting connectivity, checking resource health, managing configuration, and documenting decisions are just as important.

## Repository structure

- `infrastructure/terraform/` — Terraform configuration
- `infrastructure/helm/saleor-stack/` — Helm chart and templates
- `infrastructure/kubernetes/` — Kubernetes manifests
- `.github/workflows/ci.yml` — GitHub Actions workflow

## Project status

The application is running, and the GitHub Actions validation workflow is passing.

This is a hands-on portfolio project that I continue to improve as I learn more about AWS, Kubernetes, automation, and reliable deployments.