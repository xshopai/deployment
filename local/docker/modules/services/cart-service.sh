#!/bin/bash

# =============================================================================
# Cart Service Deployment
# =============================================================================
# Service: cart-service
# Port: 8008
# Technology: Java/Quarkus
# Database: Redis (port 6379)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="cart-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8008"
QUARKUS_PROFILE="prod"

# =============================================================================
# Cache Configuration (Redis)
# =============================================================================
REDIS_HOST="xshopai-redis"
REDIS_PORT="6379"
STORAGE_PROVIDER="redis"

# =============================================================================
# Messaging Configuration
# =============================================================================
MESSAGING_PROVIDER="rabbitmq"

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
PRODUCT_SERVICE_URL="http://xshopai-product-service:8001"
INVENTORY_SERVICE_URL="http://xshopai-inventory-service:8005"

# =============================================================================
# Deploy cart-service (Quarkus)
# =============================================================================
deploy_java_service "$SERVICE_NAME" "$SERVICE_PORT" "quarkus" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e QUARKUS_PROFILE=$QUARKUS_PROFILE \
     -e REDIS_HOST=$REDIS_HOST \
     -e REDIS_PORT=$REDIS_PORT \
     -e STORAGE_PROVIDER=$STORAGE_PROVIDER \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e PRODUCT_SERVICE_URL=$PRODUCT_SERVICE_URL \
     -e INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL \
     -e JWT_SECRET=$JWT_SECRET \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER"

# Summary
echo -e "\n${CYAN}Cart Service:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  Redis Cache:  ${GREEN}${REDIS_HOST}:${REDIS_PORT}${NC}"
