#!/bin/bash

# =============================================================================
# Payment Service Deployment
# =============================================================================
# Service: payment-service
# Port: 8009
# Technology: .NET 8/ASP.NET Core
# Database: SQL Server (port 1433)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="payment-service"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="8009"

# =============================================================================
# Database Configuration (SQL Server)
# =============================================================================
DB_HOST="xshopai-payment-sqlserver"
DB_PORT="1433"
DB_NAME="payment_service_db"
DB_USER="sa"
DB_PASS="Admin123!"
CONNECTION_STRING="Server=${DB_HOST},${DB_PORT};Database=${DB_NAME};User Id=${DB_USER};Password=${DB_PASS};TrustServerCertificate=True"

# =============================================================================
# Messaging Configuration (RabbitMQ)
# =============================================================================
MESSAGING_PROVIDER="rabbitmq"
RABBITMQ_HOST="xshopai-rabbitmq"
RABBITMQ_PORT="5672"
RABBITMQ_CONNECTION_STRING="amqp://admin:admin123@${RABBITMQ_HOST}:${RABBITMQ_PORT}/"
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
JWT_ISSUER="auth-service"
JWT_AUDIENCE="xshopai-platform"

# =============================================================================
# Deploy payment-service
# =============================================================================
deploy_dotnet_service "$SERVICE_NAME" "$SERVICE_PORT" "" \
    "-e SERVICE_NAME=$SERVICE_NAME \
     -e VERSION=$SERVICE_VERSION \
     -e DATABASE_CONNECTION_STRING=\"${CONNECTION_STRING}\" \
     -e MESSAGING_PROVIDER=$MESSAGING_PROVIDER \
     -e RABBITMQ_CONNECTION_STRING=$RABBITMQ_CONNECTION_STRING \
     -e RABBITMQ_EXCHANGE_NAME=$RABBITMQ_EXCHANGE \
     -e RABBITMQ_HOST=$RABBITMQ_HOST \
     -e RABBITMQ_PORT=$RABBITMQ_PORT \
     -e JWT_SECRET=$JWT_SECRET \
     -e JWT_ISSUER=$JWT_ISSUER \
     -e JWT_AUDIENCE=$JWT_AUDIENCE \
     -e OTEL_SERVICE_NAME=$SERVICE_NAME \
     -e OTEL_EXPORTER_ZIPKIN_ENDPOINT=$ZIPKIN_URL \
     -e OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER"

# Summary
echo -e "\n${CYAN}Payment Service:${NC}"
echo -e "  API Endpoint: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  Swagger:      ${GREEN}http://localhost:${SERVICE_PORT}/swagger${NC}"
echo -e "  Database:     ${GREEN}${DB_HOST}:${DB_PORT}${NC}"
echo -e "  Messaging:    ${GREEN}RabbitMQ (xshopai-rabbitmq:5672)${NC}"
