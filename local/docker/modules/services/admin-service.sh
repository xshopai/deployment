#!/bin/bash

# =============================================================================
# Admin Service Deployment
# =============================================================================
# Service: admin-service
# Port: 8003
# Technology: Node.js/Express
# Database: None (proxies to other services)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="admin-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8003"
NODE_ENV="production"
LOG_LEVEL="info"

# =============================================================================
# Messaging Configuration (RabbitMQ)
# =============================================================================
MESSAGING_PROVIDER="rabbitmq"
RABBITMQ_HOST="xshopai-rabbitmq"
RABBITMQ_PORT="5672"
RABBITMQ_URL="amqp://admin:admin123@${RABBITMQ_HOST}:${RABBITMQ_PORT}/"
RABBITMQ_EXCHANGE="xshopai.events"

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
# Dependent Service URLs
# =============================================================================
AUTH_SERVICE_URL="http://xshopai-auth-service:8004"
USER_SERVICE_URL="http://xshopai-user-service:8002"
PRODUCT_SERVICE_URL="http://xshopai-product-service:8001"
ORDER_SERVICE_URL="http://xshopai-order-service:8006"
INVENTORY_SERVICE_URL="http://xshopai-inventory-service:8005"

# =============================================================================
# Deploy admin-service
# =============================================================================
deploy_nodejs_service "$SERVICE_NAME" "$SERVICE_PORT" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e NODE_ENV=$NODE_ENV \
     -e LOG_LEVEL=$LOG_LEVEL \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e RABBITMQ_URL=$RABBITMQ_URL \
     -e RABBITMQ_EXCHANGE=$RABBITMQ_EXCHANGE \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER \
     -e JWT_SECRET=$JWT_SECRET \
     -e AUTH_SERVICE_URL=$AUTH_SERVICE_URL \
     -e USER_SERVICE_URL=$USER_SERVICE_URL \
     -e PRODUCT_SERVICE_URL=$PRODUCT_SERVICE_URL \
     -e ORDER_SERVICE_URL=$ORDER_SERVICE_URL \
     -e INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL" \
    ""

# Summary
echo -e "\n${CYAN}Admin Service:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  Messaging:    ${GREEN}RabbitMQ (${RABBITMQ_HOST}:${RABBITMQ_PORT})${NC}"
echo -e "  Tracing:      ${GREEN}Zipkin (${ZIPKIN_HOST}:${ZIPKIN_PORT})${NC}"
