#!/bin/bash

# =============================================================================
# Order Processor Service Deployment
# =============================================================================
# Service: order-processor-service
# Port: 8007
# Technology: Java/Spring Boot
# Database: PostgreSQL (port 5435)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="order-processor-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8007"
SPRING_PROFILES_ACTIVE="prod"

# =============================================================================
# Database Configuration (PostgreSQL)
# =============================================================================
DB_HOST="xshopai-order-processor-postgres"
DB_PORT="5432"
DB_NAME="order_processor_db"
DB_USER="admin"
DB_PASS="admin123"
DATASOURCE_URL="jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}"

# =============================================================================
# Messaging Configuration (RabbitMQ)
# =============================================================================
MESSAGING_PROVIDER="rabbitmq"
RABBITMQ_HOST="xshopai-rabbitmq"
RABBITMQ_PORT="5672"
RABBITMQ_USER="admin"
RABBITMQ_PASS="admin123"
RABBITMQ_EXCHANGE="xshopai.events"

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
ORDER_SERVICE_URL="http://xshopai-order-service:8006"
PAYMENT_SERVICE_URL="http://xshopai-payment-service:8009"
INVENTORY_SERVICE_URL="http://xshopai-inventory-service:8005"
NOTIFICATION_SERVICE_URL="http://xshopai-notification-service:8011"

# =============================================================================
# Deploy order-processor-service (Spring Boot)
# =============================================================================
deploy_java_service "$SERVICE_NAME" "$SERVICE_PORT" "spring" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE \
     -e SPRING_DATASOURCE_URL=$DATASOURCE_URL \
     -e SPRING_DATASOURCE_USERNAME=$DB_USER \
     -e SPRING_DATASOURCE_PASSWORD=$DB_PASS \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e RABBITMQ_HOST=$RABBITMQ_HOST \
     -e RABBITMQ_PORT=$RABBITMQ_PORT \
     -e RABBITMQ_USERNAME=$RABBITMQ_USER \
     -e RABBITMQ_PASSWORD=$RABBITMQ_PASS \
     -e RABBITMQ_EXCHANGE=$RABBITMQ_EXCHANGE \
     -e ORDER_SERVICE_URL=$ORDER_SERVICE_URL \
     -e PAYMENT_SERVICE_URL=$PAYMENT_SERVICE_URL \
     -e INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL \
     -e NOTIFICATION_SERVICE_URL=$NOTIFICATION_SERVICE_URL \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER"

# Summary
echo -e "\n${CYAN}Order Processor Service:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  Database:     ${GREEN}${DB_HOST}:${DB_PORT}${NC}"
echo -e "  Messaging:    ${GREEN}RabbitMQ (xshopai-rabbitmq:5672)${NC}"
