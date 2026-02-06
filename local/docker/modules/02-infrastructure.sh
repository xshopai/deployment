#!/bin/bash

# =============================================================================
# Module 02: Infrastructure Services (RabbitMQ, Redis, Mailpit)
# =============================================================================
# Deploys shared infrastructure services:
# - RabbitMQ (Message Broker)
# - Redis (Caching & Session Store)
# - Mailpit (Email Testing)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Deploying Infrastructure Services"

# =============================================================================
# RabbitMQ (Message Broker)
# =============================================================================
print_subheader "RabbitMQ Message Broker"

RABBITMQ_CONTAINER="xshopai-rabbitmq"
RABBITMQ_IMAGE="rabbitmq:3-management"
RABBITMQ_PORT="5672"
RABBITMQ_MGMT_PORT="15672"
RABBITMQ_USER="${RABBITMQ_USER:-admin}"
RABBITMQ_PASS="${RABBITMQ_PASS:-admin123}"

ensure_image "$RABBITMQ_IMAGE"

if is_container_running "$RABBITMQ_CONTAINER"; then
    print_info "RabbitMQ is already running"
else
    remove_container "$RABBITMQ_CONTAINER"
    
    docker run -d \
        --name "$RABBITMQ_CONTAINER" \
        --network "$DOCKER_NETWORK" \
        --restart unless-stopped \
        -p "${RABBITMQ_PORT}:5672" \
        -p "${RABBITMQ_MGMT_PORT}:15672" \
        -e RABBITMQ_DEFAULT_USER="$RABBITMQ_USER" \
        -e RABBITMQ_DEFAULT_PASS="$RABBITMQ_PASS" \
        -v xshopai_rabbitmq_data:/var/lib/rabbitmq \
        --health-cmd "rabbitmq-diagnostics ping" \
        --health-interval 10s \
        --health-timeout 5s \
        --health-retries 5 \
        "$RABBITMQ_IMAGE"
    
    print_success "RabbitMQ started"
fi

wait_for_container "$RABBITMQ_CONTAINER" 60

# =============================================================================
# Redis (Caching & Session Store)
# =============================================================================
print_subheader "Redis Cache Server"

REDIS_CONTAINER="xshopai-redis"
REDIS_IMAGE="redis:7-alpine"
REDIS_PORT="6380"  # Using 6380 to avoid conflict with Dapr's Redis on 6379

ensure_image "$REDIS_IMAGE"

if is_container_running "$REDIS_CONTAINER"; then
    print_info "Redis is already running"
else
    remove_container "$REDIS_CONTAINER"
    
    docker run -d \
        --name "$REDIS_CONTAINER" \
        --network "$DOCKER_NETWORK" \
        --restart unless-stopped \
        -p "${REDIS_PORT}:6379" \
        -v xshopai_redis_data:/data \
        --health-cmd "redis-cli ping | grep PONG" \
        --health-interval 10s \
        --health-timeout 5s \
        --health-retries 5 \
        "$REDIS_IMAGE" \
        redis-server --appendonly yes
    
    print_success "Redis started"
fi

wait_for_container "$REDIS_CONTAINER" 30

# =============================================================================
# Zipkin (Distributed Tracing)
# =============================================================================
print_subheader "Zipkin Distributed Tracing"

ZIPKIN_CONTAINER="xshopai-zipkin"
ZIPKIN_IMAGE="openzipkin/zipkin:latest"
ZIPKIN_PORT="9412"  # Using 9412 to avoid conflict with Dapr's Zipkin on 9411

ensure_image "$ZIPKIN_IMAGE"

if is_container_running "$ZIPKIN_CONTAINER"; then
    print_info "Zipkin is already running"
else
    remove_container "$ZIPKIN_CONTAINER"
    
    docker run -d \
        --name "$ZIPKIN_CONTAINER" \
        --network "$DOCKER_NETWORK" \
        --restart unless-stopped \
        -p "${ZIPKIN_PORT}:9411" \
        -e STORAGE_TYPE=mem \
        -v xshopai_zipkin_data:/zipkin \
        --health-cmd "wget --spider -q http://localhost:9411/health || exit 1" \
        --health-interval 10s \
        --health-timeout 5s \
        --health-retries 3 \
        "$ZIPKIN_IMAGE"
    
    print_success "Zipkin started"
fi

wait_for_container "$ZIPKIN_CONTAINER" 30

# =============================================================================
# Mailpit (Email Testing)
# =============================================================================
print_subheader "Mailpit Email Testing Server"

MAILPIT_CONTAINER="xshopai-mailpit"
MAILPIT_IMAGE="axllent/mailpit:latest"
MAILPIT_SMTP_PORT="1025"
MAILPIT_UI_PORT="8025"

ensure_image "$MAILPIT_IMAGE"

if is_container_running "$MAILPIT_CONTAINER"; then
    print_info "Mailpit is already running"
else
    remove_container "$MAILPIT_CONTAINER"
    
    docker run -d \
        --name "$MAILPIT_CONTAINER" \
        --network "$DOCKER_NETWORK" \
        --restart unless-stopped \
        -p "${MAILPIT_SMTP_PORT}:1025" \
        -p "${MAILPIT_UI_PORT}:8025" \
        -e MP_MAX_MESSAGES=5000 \
        -e MP_SMTP_AUTH_ACCEPT_ANY=1 \
        -e MP_SMTP_AUTH_ALLOW_INSECURE=1 \
        --health-cmd "wget --spider -q http://localhost:8025/ || exit 1" \
        --health-interval 10s \
        --health-timeout 5s \
        --health-retries 3 \
        "$MAILPIT_IMAGE"
    
    print_success "Mailpit started"
fi

wait_for_container "$MAILPIT_CONTAINER" 30

# =============================================================================
# Summary
# =============================================================================
print_header "Infrastructure Services Deployed"

echo -e "\n${CYAN}Service URLs:${NC}"
echo -e "  RabbitMQ Management:  ${GREEN}http://localhost:${RABBITMQ_MGMT_PORT}${NC} (${RABBITMQ_USER}/${RABBITMQ_PASS})"
echo -e "  Redis Cache:          ${GREEN}localhost:${REDIS_PORT}${NC}"
echo -e "  Zipkin Tracing:       ${GREEN}http://localhost:${ZIPKIN_PORT}${NC}"
echo -e "  Mailpit UI:           ${GREEN}http://localhost:${MAILPIT_UI_PORT}${NC}"
echo -e "  Mailpit SMTP:         ${GREEN}localhost:${MAILPIT_SMTP_PORT}${NC}"

print_success "Infrastructure deployment complete"
