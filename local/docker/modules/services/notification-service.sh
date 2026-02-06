#!/bin/bash

# =============================================================================
# Notification Service Deployment
# =============================================================================
# Service: notification-service
# Port: 8011
# Technology: Node.js/Express
# Database: None
# External: Mailpit SMTP (port 1025)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="notification-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8011"
NODE_ENV="production"
LOG_LEVEL="info"

# =============================================================================
# Email Configuration (SMTP - Mailpit)
# =============================================================================
SMTP_HOST="xshopai-mailpit"
SMTP_PORT="1025"
EMAIL_FROM="noreply@xshopai.com"

# =============================================================================
# Messaging Configuration (RabbitMQ)
# =============================================================================
MESSAGING_PROVIDER="rabbitmq"
RABBITMQ_HOST="xshopai-rabbitmq"
RABBITMQ_PORT="5672"
RABBITMQ_URL="amqp://admin:admin123@${RABBITMQ_HOST}:${RABBITMQ_PORT}/"
RABBITMQ_EXCHANGE="notification-events"

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
USER_SERVICE_URL="http://xshopai-user-service:8002"
ORDER_SERVICE_URL="http://xshopai-order-service:8006"
PRODUCT_SERVICE_URL="http://xshopai-product-service:8001"

# =============================================================================
# Deploy notification-service
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
     -e SMTP_HOST=$SMTP_HOST \
     -e SMTP_PORT=$SMTP_PORT \
     -e EMAIL_FROM=$EMAIL_FROM \
     -e USER_SERVICE_URL=$USER_SERVICE_URL \
     -e ORDER_SERVICE_URL=$ORDER_SERVICE_URL \
     -e PRODUCT_SERVICE_URL=$PRODUCT_SERVICE_URL" \
    ""

# Summary
echo -e "\n${CYAN}Notification Service:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  SMTP Server:  ${GREEN}${SMTP_HOST}:${SMTP_PORT}${NC}"
echo -e "  Messaging:    ${GREEN}RabbitMQ (${RABBITMQ_HOST}:${RABBITMQ_PORT})${NC}"
echo -e "  Tracing:      ${GREEN}Zipkin (${ZIPKIN_HOST}:${ZIPKIN_PORT})${NC}"
echo -e "  Mailpit UI:   ${GREEN}http://localhost:8025${NC}"
