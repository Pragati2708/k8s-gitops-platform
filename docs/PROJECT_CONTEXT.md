# Current Implementation Status

Latest continuation completed:
- Added GitHub Actions workflow in k8s-gitops-platform to detect changed services, validate them, build Docker images, push to ECR, and update k8s-gitops-config image tags for ArgoCD.
- Added Terraform-managed ECR repositories for legacy-service, transaction-service, and notification-service with scan-on-push and lifecycle cleanup.
- Hardened service Dockerfiles to use node:18-alpine, npm ci, production env, .dockerignore, and non-root runtime.
- Added /health endpoints for all three Node services.
- Fixed k8s-gitops-config legacy-service values typo from iimage to image.
- Updated Helm charts to use ECR image repositories, imagePullPolicy, readiness probes, and liveness probes.
- Aligned Helm legacy service name to legacy-service so transaction-service can reach it in EKS.

Required GitHub secrets for CI/CD:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- GITOPS_TOKEN with permission to push to Pragati2708/k8s-gitops-config

Verification completed:
- npm test passed for legacy-service, transaction-service, and notification-service.
- helm template passed for legacy-service, transaction-service, and notification-service.
- terraform fmt completed for terraform-eks.

Verification not completed:
- Local docker build could not run because the Docker daemon was not running.
- terraform validate could not run because locally cached Terraform provider plugins failed to load; run terraform init again before validating/applying.

Current pending work:
1. Apply Terraform ECR repository changes.
2. Run GitHub Actions pipeline and confirm images are pushed to ECR.
3. Confirm ArgoCD sync deploys SHA-tagged images from k8s-gitops-config.
4. Add frontend.
5. Add RDS database.
6. Add ALB ingress.
7. Add Route53 DNS.
8. Add HTTPS ACM certificate.
9. Add Secrets Manager.
10. Add autoscaling.

# Future Production Enhancement Plan

The current DevOps project will be upgraded into a full production-style 3-tier application.

## Application Architecture

Frontend:
- React.js based UI
- Modern dashboard design
- User-friendly interface
- Containerized with Docker
- Served using Nginx container


Backend:

Microservices:

1. legacy-service
2. transaction-service
3. notification-service


Communication:

React UI
    |
REST APIs
    |
Backend services
    |
PostgreSQL Database


## Database Layer

Use:

Amazon RDS PostgreSQL

Terraform will provision:

- RDS instance
- DB subnet group
- Security group
- Private subnet placement


Database requirements:

Tables:

users
transactions
notifications


Backend services will connect using:

DATABASE_HOST
DATABASE_USER
DATABASE_PASSWORD


Credentials should come from:

AWS Secrets Manager
        +
External Secrets Operator


## Public Access Layer

Use:

AWS Load Balancer Controller

Create:

Application Load Balancer


Traffic flow:

Route53 DNS

app.domain.com

        |

ALB HTTPS Listener

        |

Kubernetes Ingress

        |

Frontend Service


## HTTPS

Use:

AWS Certificate Manager

Configure:

TLS certificate
HTTPS 443


## Kubernetes Improvements


Add:

Horizontal Pod Autoscaler

Example:

frontend:
min replicas: 2
max replicas: 10


backend services:
min replicas: 2


Add:

Resource requests:

CPU
Memory


Add:

Health checks:

readinessProbe
livenessProbe


## CI/CD Enhancement


GitHub Actions should:

1. Detect changed service
2. Build Docker image
3. Push image to Amazon ECR
4. Update image tag
5. Commit to GitOps repo


ArgoCD:

Automatically syncs deployment.


## Monitoring Enhancement


Prometheus should monitor:

- frontend availability
- API latency
- pod restarts
- CPU
- memory


Grafana dashboards:

- Application dashboard
- Kubernetes dashboard


Alerts:

Slack notifications for:

- Pod crash
- High CPU
- API failures


## Logging


Add:

Fluent Bit

Send logs to:

CloudWatch Logs
