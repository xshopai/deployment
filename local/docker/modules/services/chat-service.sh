#!/bin/bash

# =============================================================================
# Chat Service Deployment
# =============================================================================
# Service: chat-service
# Port: 8013
# Technology: Node.js/Express (WebSocket support)
# Database: None (in-memory or Redis for scaling)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="chat-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8013"
NODE_ENV="production"
LOG_LEVEL="info"

# =============================================================================
# Cache Configuration (Redis)
# =============================================================================
REDIS_HOST="xshopai-redis"
REDIS_PORT="6379"

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
# Dependent Service URLs
# =============================================================================
PRODUCT_SERVICE_URL="http://xshopai-product-service:8001"
ORDER_SERVICE_URL="http://xshopai-order-service:8006"
USER_SERVICE_URL="http://xshopai-user-service:8002"
INVENTORY_SERVICE_URL="http://xshopai-inventory-service:8005"

# =============================================================================
# Deploy chat-service
# =============================================================================
deploy_nodejs_service "$SERVICE_NAME" "$SERVICE_PORT" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e NODE_ENV=$NODE_ENV \
     -e LOG_LEVEL=$LOG_LEVEL \
     -e REDIS_HOST=$REDIS_HOST \
     -e REDIS_PORT=$REDIS_PORT \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER \
     -e PRODUCT_SERVICE_URL=$PRODUCT_SERVICE_URL \
     -e ORDER_SERVICE_URL=$ORDER_SERVICE_URL \
     -e USER_SERVICE_URL=$USER_SERVICE_URL \
     -e INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL"

# Summary
echo -e "\n${CYAN}Chat Service:${NC}"
echo -e "  API Endpoint:     ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  WebSocket:        ${GREEN}ws://localhost:${SERVICE_PORT}${NC}"
echo -e "  Tracing:          ${GREEN}Zipkin (xshopai-zipkin:9411)${NC}"
