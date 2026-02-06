#!/bin/bash

# =============================================================================
# Audit Service Deployment
# =============================================================================
# Service: audit-service
# Port: 8012
# Technology: Node.js/Express
# Database: PostgreSQL (port 5434)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="audit-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8012"
NODE_ENV="production"
LOG_LEVEL="info"

# =============================================================================
# Database Configuration (PostgreSQL)
# =============================================================================
DB_HOST="xshopai-audit-postgres"
DB_PORT="5432"
DB_NAME="audit_service_db"
DB_USER="admin"
DB_PASS="admin123"

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
# Deploy audit-service
# =============================================================================
deploy_nodejs_service "$SERVICE_NAME" "$SERVICE_PORT" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e NODE_ENV=$NODE_ENV \
     -e LOG_LEVEL=$LOG_LEVEL \
     -e POSTGRES_HOST=$DB_HOST \
     -e POSTGRES_PORT=$DB_PORT \
     -e POSTGRES_USER=$DB_USER \
     -e POSTGRES_PASSWORD=$DB_PASS \
     -e POSTGRES_DB=$DB_NAME \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e RABBITMQ_URL=$RABBITMQ_URL \
     -e RABBITMQ_EXCHANGE=$RABBITMQ_EXCHANGE \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER"

# Summary
echo -e "\n${CYAN}Audit Service:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  Database:     ${GREEN}${DB_HOST}:${DB_PORT}${NC}"
echo -e "  Messaging:    ${GREEN}RabbitMQ (xshopai-rabbitmq:5672)${NC}"
echo -e "  Tracing:      ${GREEN}Zipkin (xshopai-zipkin:9411)${NC}"
