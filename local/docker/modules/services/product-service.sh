#!/bin/bash

# =============================================================================
# Product Service Deployment
# =============================================================================
# Service: product-service
# Port: 8001
# Technology: Python/FastAPI
# Database: MongoDB (port 27019)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="product-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8001"
ENVIRONMENT="production"
LOG_LEVEL="INFO"

# =============================================================================
# Database Configuration (MongoDB)
# =============================================================================
DB_HOST="xshopai-product-mongodb"
DB_PORT="27017"
DB_NAME="product_service_db"
DB_USER="admin"
DB_PASS="admin123"
MONGODB_URI="mongodb://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}?authSource=admin"

# =============================================================================
# Messaging Configuration (RabbitMQ)
# =============================================================================
MESSAGING_PROVIDER="rabbitmq"
RABBITMQ_HOST="xshopai-rabbitmq"
RABBITMQ_PORT="5672"
RABBITMQ_URL="amqp://admin:admin123@${RABBITMQ_HOST}:${RABBITMQ_PORT}/"
RABBITMQ_EXCHANGE="product-events"

# =============================================================================
# Observability Configuration (Zipkin)
# =============================================================================
ZIPKIN_HOST="xshopai-zipkin"
ZIPKIN_PORT="9411"
ZIPKIN_URL="http://${ZIPKIN_HOST}:${ZIPKIN_PORT}/api/v2/spans"
OTEL_TRACES_EXPORTER="zipkin"

# =============================================================================
# Security Configuration
# =============================================================================
JWT_SECRET="q9X2K8vT1mLpR4sNz7YcHd6Qw3EfUaBjM5tGx0VrCi8="

# =============================================================================
# Deploy product-service
# =============================================================================
deploy_python_service "$SERVICE_NAME" "$SERVICE_PORT" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e ENVIRONMENT=$ENVIRONMENT \
     -e LOG_LEVEL=$LOG_LEVEL \
     -e MONGODB_URI=$MONGODB_URI \
     -e MONGODB_DB_NAME=$DB_NAME \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e RABBITMQ_URL=$RABBITMQ_URL \
     -e RABBITMQ_EXCHANGE=$RABBITMQ_EXCHANGE \
     -e JWT_SECRET=$JWT_SECRET \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER" \
    ""

# Summary
echo -e "\n${CYAN}Product Service:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  API Docs:     ${GREEN}http://localhost:${SERVICE_PORT}/docs${NC}"
echo -e "  Database:     ${GREEN}${DB_HOST}:${DB_PORT}${NC}"
echo -e "  Messaging:    ${GREEN}RabbitMQ (${RABBITMQ_HOST}:${RABBITMQ_PORT})${NC}"
echo -e "  Tracing:      ${GREEN}Zipkin (${ZIPKIN_HOST}:${ZIPKIN_PORT})${NC}"
