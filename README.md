# Saleor on Amazon EKS

In this project, I worked on deploying Saleor, an open-source e-commerce platform, on Amazon EKS. I wanted to understand how the application runs on Kubernetes and how its different components work together.

I also worked with Helm, Terraform, GitHub Actions, and monitoring tools to manage the setup, check configuration changes, and keep track of the application's health.

## Architecture

I deployed Saleor on Amazon EKS and used an AWS Application Load Balancer (ALB) to handle incoming traffic. The ALB routes requests to the Saleor dashboard, API, and monitoring services based on the domain name.

I also configured HTTPS using an AWS Certificate Manager (ACM) certificate, with HTTP requests redirected to HTTPS. Amazon RDS provides the PostgreSQL database, while Valkey supports caching and background tasks.

Prometheus and Grafana help monitor the environment, and Alertmanager sends email notifications when configured alerts are triggered.

### Architecture Diagram

```mermaid
flowchart TB
    User["Users / Browser"]

    subgraph AWS["AWS Cloud"]
        ALB["Application Load Balancer<br/>HTTP → HTTPS"]

        subgraph EKS["Amazon EKS Cluster"]
            Ingress["Kubernetes Ingress<br/>Host-based routing"]

            subgraph App["Saleor Application"]
                Dashboard["Saleor Dashboard"]
                API["Saleor API"]
                Worker["Background Worker"]
                Valkey[("Valkey Cache")]
            end

            subgraph Monitoring["Monitoring"]
                Proxy["Monitoring Proxy"]
                Prometheus["Prometheus"]
                Grafana["Grafana"]
                Alertmanager["Alertmanager"]
            end
        end

        RDS[("Amazon RDS<br/>PostgreSQL")]
        ACM["AWS Certificate Manager<br/>TLS Certificate"]
    end

    User --> ALB
    ACM -. "HTTPS certificate" .-> ALB
    ALB --> Ingress

    Ingress -->|"dashboard.mhhuzaifa.com"| Dashboard
    Ingress -->|"api.mhhuzaifa.com"| API
    Ingress -->|"grafana / alerts domains"| Proxy

    Dashboard --> API
    API --> RDS
    Worker --> RDS
    API --> Valkey
    Worker --> Valkey

    Proxy --> Grafana
    Prometheus --> Grafana
    Prometheus --> Alertmanager
    Alertmanager --> Email["Email Notifications"]
```
## Tools & Technologies

- **AWS:** Amazon EKS, Application Load Balancer (ALB), AWS Certificate Manager (ACM), Amazon RDS, EC2, EBS
- **Containers & Orchestration:** Docker, Kubernetes
- **Deployment:** Helm
- **Infrastructure as Code:** Terraform
- **Monitoring & Alerting:** Prometheus, Grafana, Alertmanager
- **CI/CD:** GitHub Actions
- **Database & Cache:** PostgreSQL, Valkey
- **Other:** Linux, Git, GitHub

## CI/CD

I added a GitHub Actions workflow to check the Helm chart whenever changes are pushed or a pull request is opened.

The workflow runs Helm linting and validates the Kubernetes templates before changes are merged. This helps catch configuration issues early.

The workflow currently focuses on validation; it does not automatically deploy changes to the EKS cluster.

## Monitoring & Alerting

I set up Prometheus and Grafana to monitor the Kubernetes environment and view cluster metrics. Alertmanager handles alerts and sends email notifications when configured alert rules are triggered.

This setup helped me explore how monitoring can make it easier to spot problems and investigate the health of a running application.

## Security & Configuration

Application credentials are managed through Kubernetes Secrets rather than being written directly into the application manifests.

The project also uses AWS infrastructure and Kubernetes configuration to manage access between components. Before using a similar setup in production, security groups, database access, secret management, and permissions should be reviewed carefully.

## What I Learned

Working on this project gave me practical experience deploying an application on Kubernetes and managing its configuration with Helm and Terraform.

I also worked with Amazon RDS, set up monitoring and email alerts, and used GitHub Actions to validate configuration changes. Troubleshooting the setup helped me better understand how application components, infrastructure, and monitoring fit together.

## Repository Structure

```text
project-01-eks/
├── .github/
│   └── workflows/              # GitHub Actions workflow
├── docs/
│   └── screenshots/            # Project screenshots and evidence
├── infrastructure/
│   ├── helm/                   # Helm chart for Saleor
│   ├── kubernetes/             # Kubernetes manifests
│   └── terraform/              # Infrastructure configuration
└── README.md                   # Project documentation
```

The repository contains the Helm chart, Kubernetes manifests, Terraform configuration, CI workflow, and screenshots documenting the project.

## Screenshots & Evidence

### Saleor Dashboard
![Saleor Dashboard](docs/screenshots/dashboard.png)

### Saleor API
![Saleor API](docs/screenshots/api-1.png)

![Saleor API Details](docs/screenshots/api-2.png)

### Grafana Monitoring
![Grafana Monitoring Dashboard](docs/screenshots/grafana.png)

### Alerting Rules
![Prometheus Alerting Rules](docs/screenshots/alerts.png)

### Alertmanager Email Notifications
![Alertmanager Email Notification](docs/screenshots/email-notification.png)

### GitHub Actions CI/CD
![GitHub Actions Workflow](docs/screenshots/github-ci-cd.png)
