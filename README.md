# xshopai Platform Deployment

This repository contains all deployment configurations and scripts for the xshopai e-commerce platform across different environments.

## 📋 Overview

The xshopai platform can be deployed to multiple environments:

- **Local Development** - Docker containers with Dapr sidecars
- **Azure Container Apps** - Serverless containers (coming soon)
- **Azure Kubernetes Service** - Full Kubernetes orchestration (coming soon)
- **Docker Compose** - Alternative local deployment (coming soon)

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** - [Install Docker](https://www.docker.com/products/docker-desktop)
- **Dapr CLI** - [Install Dapr](https://docs.dapr.io/getting-started/install-dapr-cli/)
- **Git** - For cloning the repository

### Local Docker Deployment

The fastest way to get started:

```bash
# Navigate to local Docker deployment
cd local/docker

# Deploy entire platform
./deploy.sh --all

# Or deploy specific services
./deploy.sh --infra --databases
./deploy.sh --inventory-service --product-service
```

**Access the platform:**
- Customer UI: http://localhost:3000
- Admin UI: http://localhost:3001
- RabbitMQ Management: http://localhost:15672 (admin/admin123)
- Zipkin Tracing: http://localhost:9411
- Mailpit (Email Testing): http://localhost:8025

## 📁 Repository Structure

```
deployment/
├── local/                      # Local development deployments
│   └── docker/                 # Docker-based deployment (current)
│       ├── deploy.sh           # Main deployment script
│       ├── cleanup.sh          # Cleanup script
│       ├── status.sh           # Status checker
│       └── modules/            # Deployment modules
│
├── azure/                      # Azure deployments (coming soon)
├── config/                     # Shared configuration
├── scripts/                    # Cross-environment scripts
└── docs/                       # Deployment documentation
```

## 🎯 Deployment Options

| Environment | Technology | Use Case | Setup Time | Status |
|-------------|------------|----------|------------|--------|
| **Local** | Docker + Dapr | Development & Testing | 5-10 min | ✅ Available |
| **Local** | Docker Compose | Simpler local setup | 3-5 min | 🔄 Coming Soon |
| **Azure** | Container Apps | Staging/Production | 30 min | 🔄 Coming Soon |
| **Azure** | AKS | Enterprise/Scale | 1 hour | 🔄 Coming Soon |

## 📚 Documentation

- [Local Docker Deployment Guide](local/docker/docs/README.md)
- [Azure Container Apps Deployment](docs/azure-aca-deployment.md) (coming soon)
- [Kubernetes Deployment](docs/kubernetes-deployment.md) (coming soon)

## 🛠️ Common Commands

### Local Docker

```bash
cd local/docker

# Deploy everything
./deploy.sh --all

# Deploy specific service
./deploy.sh --inventory-service

# Check status
./status.sh

# View logs
./logs.sh inventory-service

# Stop everything
./stop.sh
```

## 🤝 Contributing

When adding new deployment configurations:

1. Follow the environment-first folder structure
2. Document everything with README files
3. Test on a fresh machine before committing
4. Update this main README

## 📝 Release Notes

### v1.0.0 (Current)
- ✅ Local Docker deployment with Dapr
- ✅ Auto-build missing Docker images
- ✅ Dapr auto-initialization
- ✅ All 13+ microservices supported

### Upcoming
- 🔄 Docker Compose alternative
- 🔄 Azure Container Apps deployment
- 🔄 Kubernetes manifests
- 🔄 Terraform/Bicep templates

---

**Current Status**: Local Docker deployment fully functional ✅  
**Next Focus**: Azure Container Apps deployment 🚀
