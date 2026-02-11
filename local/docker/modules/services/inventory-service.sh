#!/bin/bash

# =============================================================================
# Inventory Service Deployment
# =============================================================================
# Service: inventory-service
# Port: 8005
# Technology: Python/FastAPI
# Database: MySQL (port 3306)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="inventory-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8005"
ENVIRONMENT="development"
LOG_LEVEL="DEBUG"
LOG_FORMAT="console"
LOG_TO_CONSOLE="true"
LOG_TO_FILE="false"

# =============================================================================
# Database Configuration (MySQL)
# =============================================================================
DB_HOST="xshopai-inventory-mysql"
DB_PORT="3306"
DB_NAME="inventory_service_db"
MYSQL_CONNECTION="mysql+pymysql://admin:admin123@${DB_HOST}:${DB_PORT}"

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
SERVICE_PRODUCT_TOKEN="prd_8fK29sLmQx7vR2nT5yZc4WpJ1aH6uE"
SERVICE_ORDER_TOKEN="ord_Y7mNx3QaP9tLs2Vk8HdR5cBw1Zj4Fe"
SERVICE_CART_TOKEN="crt_T6pLd9XvR3sNm1Qw8KaZ5uHc2Bj7Ye"
SERVICE_WEBBFF_TOKEN="bff_W2rTk8LpQ5nVz1Xm9HsDc4Jy6Fa3Ne"

# =============================================================================
# Deploy inventory-service
# =============================================================================
deploy_python_service "$SERVICE_NAME" "$SERVICE_PORT" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e PORT=$SERVICE_PORT \
     -e ENVIRONMENT=$ENVIRONMENT \
     -e LOG_LEVEL=$LOG_LEVEL \
     -e LOG_FORMAT=$LOG_FORMAT \
     -e LOG_TO_CONSOLE=$LOG_TO_CONSOLE \
     -e LOG_TO_FILE=$LOG_TO_FILE \
     -e MYSQL_SERVER_CONNECTION=$MYSQL_CONNECTION \
     -e DB_NAME=$DB_NAME \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e RABBITMQ_URL=$RABBITMQ_URL \
     -e RABBITMQ_EXCHANGE=$RABBITMQ_EXCHANGE \
     -e ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER \
     -e JWT_SECRET=$JWT_SECRET \
     -e SERVICE_PRODUCT_TOKEN=$SERVICE_PRODUCT_TOKEN \
     -e SERVICE_ORDER_TOKEN=$SERVICE_ORDER_TOKEN \
     -e SERVICE_CART_TOKEN=$SERVICE_CART_TOKEN \
     -e SERVICE_WEBBFF_TOKEN=$SERVICE_WEBBFF_TOKEN"

# Summary
echo -e "\n${CYAN}Inventory Service:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  API Docs:     ${GREEN}http://localhost:${SERVICE_PORT}/docs${NC}"
echo -e "  Database:     ${GREEN}${DB_HOST}:${DB_PORT}${NC}"
