# xshopai Local Docker Deployment

This folder contains scripts to deploy the entire xshopai microservices platform locally using pure Docker commands. The deployment system supports both full platform deployment and individual service deployment.

## Overview

The local Docker deployment creates all infrastructure, databases, and services needed to run the complete xshopai platform on your local machine. This approach provides:

- **Full Platform Testing**: Test the entire microservices ecosystem locally
- **Production Parity**: Same container images as production deployments
- **Individual Service Deployment**: Deploy and debug single services independently
- **Optional Dapr Support**: Run with or without Dapr sidecars
- **Pre-built Images**: Assumes images are already built (use `--build` to build)

## Prerequisites

### Required Tools

- **Docker**: Docker Engine 20.10+ or Docker Desktop

**Note**: Dapr CLI is automatically checked and initialized by the deployment script. If not found, you'll receive installation instructions.

### System Requirements

- **RAM**: Minimum 8GB, Recommended 16GB+
- **Disk**: At least 20GB free space
- **CPU**: 4+ cores recommended

**Docker Desktop Resource Settings**:

- Memory: 8GB minimum (16GB recommended)
- CPUs: 4 minimum
- Disk: 50GB+

### Repository Structure

**IMPORTANT**: All xshopai repositories must be cloned under a common parent directory. The deployment scripts expect this structure:

```
xshopai/                          # Parent directory (can be any name)
├── admin-service/
├── admin-ui/
├── audit-service/
├── auth-service/
├── cart-service/
├── chat-service/
├── customer-ui/
├── deployment/                   # This repository
│   └── local/
│       └── docker/
│           ├── deploy.sh         # Run from here
│           └── modules/
├── inventory-service/
├── notification-service/
├── order-processor-service/
├── order-service/
├── payment-service/
├── product-service/
├── review-service/
├── user-service/
├── web-bff/
├── scripts/                      # Optional: shared scripts
├── docs/                         # Optional: documentation
└── .github/                      # Optional: GitHub org files
```

**Why this matters**: The deployment scripts calculate paths relative to the workspace root. If repositories are not at the same level, the scripts won't find service source code and Docker configurations.

### Clone All Repositories

```bash
# Create parent directory
mkdir -p ~/xshopai
cd ~/xshopai

# Clone all service repositories
git clone https://github.com/xshopai/admin-service.git
git clone https://github.com/xshopai/admin-ui.git
git clone https://github.com/xshopai/audit-service.git
git clone https://github.com/xshopai/auth-service.git
git clone https://github.com/xshopai/cart-service.git
git clone https://github.com/xshopai/chat-service.git
git clone https://github.com/xshopai/customer-ui.git
git clone https://github.com/xshopai/deployment.git          # This repo
git clone https://github.com/xshopai/inventory-service.git
git clone https://github.com/xshopai/notification-service.git
git clone https://github.com/xshopai/order-processor-service.git
git clone https://github.com/xshopai/order-service.git
git clone https://github.com/xshopai/payment-service.git
git clone https://github.com/xshopai/product-service.git
git clone https://github.com/xshopai/review-service.git
git clone https://github.com/xshopai/user-service.git
git clone https://github.com/xshopai/web-bff.git

# Navigate to deployment scripts
cd deployment/local/docker
```

## Quick Start

```bash
# Deploy everything (all services, databases, infrastructure)
./deploy.sh

# Deploy only infrastructure and databases
./deploy.sh --infra --databases

# Deploy a single service (for debugging)
./deploy.sh --auth-service

# Deploy multiple specific services
./deploy.sh --auth-service --user-service --product-service

# Deploy with Dapr sidecars enabled
./deploy.sh --dapr --all

# Build images before deploying
./deploy.sh --build --product-service

# Clean and redeploy everything
./deploy.sh --clean --all
```

## Resources Created

### Infrastructure Services

| Resource       | Container Name     | Ports       | Description                                     |
| -------------- | ------------------ | ----------- | ----------------------------------------------- |
| RabbitMQ       | `xshopai-rabbitmq` | 5672, 15672 | Message broker for async communication          |
| Mailpit        | `xshopai-mailpit`  | 1025, 8025  | Email testing server                            |
| Dapr Redis     | `dapr_redis`       | 6379        | Dapr state store and cache (from `dapr init`)   |
| Dapr Zipkin    | `dapr_zipkin`      | 9411        | Dapr distributed tracing (from `dapr init`)     |
| Dapr Placement | `dapr_placement`   | 6050        | Dapr actor placement service (from `dapr init`) |
| Dapr Scheduler | `dapr_scheduler`   | 6060        | Dapr workflow scheduler (from `dapr init`)      |

### Database Instances

| Database   | Container Name                     | Port  | Used By                 |
| ---------- | ---------------------------------- | ----- | ----------------------- |
| MongoDB    | `xshopai-auth-mongodb`             | 27017 | auth-service            |
| MongoDB    | `xshopai-user-mongodb`             | 27018 | user-service            |
| MongoDB    | `xshopai-product-mongodb`          | 27019 | product-service         |
| MongoDB    | `xshopai-review-mongodb`           | 27020 | review-service          |
| PostgreSQL | `xshopai-audit-postgres`           | 5434  | audit-service           |
| PostgreSQL | `xshopai-order-processor-postgres` | 5435  | order-processor-service |
| SQL Server | `xshopai-payment-sqlserver`        | 1433  | payment-service         |
| SQL Server | `xshopai-order-sqlserver`          | 1434  | order-service           |
| MySQL      | `xshopai-inventory-mysql`          | 3306  | inventory-service       |

### Application Services

| Service              | Container Name                    | Port | Technology          | Database   |
| -------------------- | --------------------------------- | ---- | ------------------- | ---------- |
| Web BFF              | `xshopai-web-bff`                 | 8014 | Node.js/TypeScript  | -          |
| Auth Service         | `xshopai-auth-service`            | 8004 | Node.js/Express     | MongoDB    |
| User Service         | `xshopai-user-service`            | 8002 | Node.js/Express     | MongoDB    |
| Admin Service        | `xshopai-admin-service`           | 8003 | Node.js/Express     | -          |
| Product Service      | `xshopai-product-service`         | 8001 | Python/FastAPI      | MongoDB    |
| Inventory Service    | `xshopai-inventory-service`       | 8005 | Python/FastAPI      | MySQL      |
| Order Service        | `xshopai-order-service`           | 8006 | .NET 8/ASP.NET Core | SQL Server |
| Payment Service      | `xshopai-payment-service`         | 8009 | .NET 8/ASP.NET Core | SQL Server |
| Cart Service         | `xshopai-cart-service`            | 8008 | Java 21/Quarkus     | Redis      |
| Order Processor      | `xshopai-order-processor-service` | 8007 | Java/Spring Boot    | PostgreSQL |
| Review Service       | `xshopai-review-service`          | 8010 | Node.js/Express     | MongoDB    |
| Notification Service | `xshopai-notification-service`    | 8011 | Node.js/Express     | -          |
| Audit Service        | `xshopai-audit-service`           | 8012 | Node.js/Express     | PostgreSQL |
| Chat Service         | `xshopai-chat-service`            | 8013 | Node.js/Express     | -          |

### Frontend Applications

| Application | Container Name        | Port | Technology  |
| ----------- | --------------------- | ---- | ----------- |
| Customer UI | `xshopai-customer-ui` | 3000 | React/nginx |
| Admin UI    | `xshopai-admin-ui`    | 3001 | React/nginx |

## Usage

### Deployment Options

The deployment script supports flexible deployment patterns:

**Full Platform Deployment:**

```bash
# Deploy everything (infrastructure, databases, all services)
./deploy.sh

# Or explicitly
./deploy.sh --all
```

**Infrastructure and Databases Only:**

```bash
# Deploy only infrastructure (RabbitMQ, Mailpit) and all databases
./deploy.sh --infra --databases

# Shorter version
./deploy.sh --infra --dbs
```

**Individual Service Deployment:**

```bash
# Deploy a single service (for debugging/development)
./deploy.sh --auth-service
./deploy.sh --product-service
./deploy.sh --inventory-service

# Multiple specific services
./deploy.sh --auth-service --user-service --product-service
```

**Frontend Applications:**

```bash
# Deploy UIs only
./deploy.sh --customer-ui
./deploy.sh --admin-ui
./deploy.sh --customer-ui --admin-ui
```

**With Dapr Sidecars:**

```bash
# Deploy services with Dapr support
./deploy.sh --dapr --auth-service
./deploy.sh --dapr --all
```

**Build Images:**

```bash
# Always rebuild images before deploying
./deploy.sh --build --product-service

# Build and deploy everything
./deploy.sh --build --all
```

**Clean Deployment:**

```bash
# Remove existing containers and redeploy
./deploy.sh --clean --all
./deploy.sh --clean --auth-service
```

## Accessing the Platform

### Frontend Applications

- **Customer UI**: http://localhost:3000
- **Admin UI**: http://localhost:3001

### Infrastructure UIs

- **RabbitMQ Management**: http://localhost:15672 (admin / admin123)
- **Dapr Zipkin**: http://localhost:9411
- **Mailpit**: http://localhost:8025
