#!/bin/bash

# =============================================================================
# Web BFF (Backend For Frontend) Deployment
# =============================================================================
# Service: web-bff
# Port: 8014
# Technology: Node.js/TypeScript/Express
# Database: None (aggregates backend services)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="web-bff"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8014"
NODE_ENV="production"
LOG_LEVEL="info"

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
AUTH_SERVICE_URL="http://xshopai-auth-service:8004"
USER_SERVICE_URL="http://xshopai-user-service:8002"
PRODUCT_SERVICE_URL="http://xshopai-product-service:8001"
CART_SERVICE_URL="http://xshopai-cart-service:8008"
ORDER_SERVICE_URL="http://xshopai-order-service:8006"
REVIEW_SERVICE_URL="http://xshopai-review-service:8010"
INVENTORY_SERVICE_URL="http://xshopai-inventory-service:8005"
ADMIN_SERVICE_URL="http://xshopai-admin-service:8003"
CHAT_SERVICE_URL="http://xshopai-chat-service:8013"

# =============================================================================
# Deploy web-bff
# =============================================================================
deploy_nodejs_service "$SERVICE_NAME" "$SERVICE_PORT" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e NODE_ENV=$NODE_ENV \
     -e LOG_LEVEL=$LOG_LEVEL \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER \
     -e JWT_SECRET=$JWT_SECRET \
     -e AUTH_SERVICE_URL=$AUTH_SERVICE_URL \
     -e USER_SERVICE_URL=$USER_SERVICE_URL \
     -e PRODUCT_SERVICE_URL=$PRODUCT_SERVICE_URL \
     -e CART_SERVICE_URL=$CART_SERVICE_URL \
     -e ORDER_SERVICE_URL=$ORDER_SERVICE_URL \
     -e REVIEW_SERVICE_URL=$REVIEW_SERVICE_URL \
     -e INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL \
     -e ADMIN_SERVICE_URL=$ADMIN_SERVICE_URL \
     -e CHAT_SERVICE_URL=$CHAT_SERVICE_URL" \
    ""

# Summary
echo -e "\n${CYAN}Web BFF:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  Tracing:      ${GREEN}Zipkin (${ZIPKIN_HOST}:${ZIPKIN_PORT})${NC}"
echo -e "  This service aggregates:"
echo -e "    - Auth Service"
echo -e "    - User Service"
echo -e "    - Product Service"
echo -e "    - Cart Service"
echo -e "    - Order Service"
echo -e "    - Review Service"
echo -e "    - Inventory Service"
