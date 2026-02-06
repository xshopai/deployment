#!/bin/bash

# =============================================================================
# xshopai Local Docker Deployment Orchestrator
# =============================================================================
# Main entry point for deploying xshopai platform locally using Docker.
# Supports deploying everything or individual services.
#
# Architecture:
#   - Modular design: Each service has its own deployment script
#   - Individual deployment: Run any single service for debugging
#   - Pre-built images: Assumes Docker images are already built
#   - Optional Dapr: Supports running with or without Dapr sidecars
#
# Usage:
#   ./deploy.sh [options] [services...]
#
# Options:
#   --all                Deploy everything (default if no services specified)
#   --infra              Deploy infrastructure only (RabbitMQ, Redis, etc.)
#   --databases          Deploy databases only
#   --services           Deploy all application services
#   --frontends          Deploy frontend applications only
#   --build              Build Docker images before deploying
#   --dapr               Enable Dapr sidecars for services
#   --clean              Remove all containers and volumes before deploying
#   --parallel           Deploy services in parallel (faster, default for --all)
#   --sequential         Deploy services sequentially (useful for debugging)
#   --seed               Seed demo data (users, products, inventory) after deployment
#   --help               Show this help message
#
# Individual Services (can combine multiple):
#   --auth-service       Deploy Auth Service
#   --user-service       Deploy User Service
#   --product-service    Deploy Product Service
#   --inventory-service  Deploy Inventory Service
#   --order-service      Deploy Order Service
#   --payment-service    Deploy Payment Service
#   --cart-service       Deploy Cart Service
#   --review-service     Deploy Review Service
#   --admin-service      Deploy Admin Service
#   --notification-service  Deploy Notification Service
#   --audit-service      Deploy Audit Service
#   --chat-service       Deploy Chat Service
#   --order-processor-service  Deploy Order Processor Service
#   --web-bff            Deploy Web BFF
#   --customer-ui        Deploy Customer UI
#   --admin-ui           Deploy Admin UI
#
# Examples:
#   ./deploy.sh                           # Deploy everything
#   ./deploy.sh --infra --databases       # Deploy only infra and databases
#   ./deploy.sh --auth-service            # Deploy only auth-service
#   ./deploy.sh --auth-service --user-service  # Deploy multiple services
#   ./deploy.sh --build --product-service # Build and deploy product-service
#   ./deploy.sh --dapr --all              # Deploy all with Dapr sidecars
#   ./deploy.sh --clean --all             # Clean and redeploy everything
#   ./deploy.sh --parallel --services     # Deploy all services in parallel
#   ./deploy.sh --sequential --all        # Deploy everything sequentially
#   ./deploy.sh --seed                    # Deploy and seed demo data
# =============================================================================

set -e

# Capture start time for deployment duration
DEPLOY_START_TIME=$(date +%s)

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
SERVICES_DIR="$MODULES_DIR/services"

# Source common utilities
source "$MODULES_DIR/common.sh"

# -----------------------------------------------------------------------------
# Default configuration
# -----------------------------------------------------------------------------
DEPLOY_ALL=false
DEPLOY_INFRA=false
DEPLOY_DBS=false
DEPLOY_SERVICES=false
DEPLOY_FRONTENDS=false
BUILD_IMAGES=false
DAPR_ENABLED=false
CLEAN_FIRST=false
PARALLEL_DEPLOY=true    # Default to parallel
SEQUENTIAL_DEPLOY=false
SEED_DATA=false

# Individual service flags
declare -A SERVICES_TO_DEPLOY

# All available services
ALL_SERVICES=(
    "auth-service"
    "user-service"
    "product-service"
    "inventory-service"
    "order-service"
    "payment-service"
    "cart-service"
    "review-service"
    "admin-service"
    "notification-service"
    "audit-service"
    "chat-service"
    "order-processor-service"
    "web-bff"
    "customer-ui"
    "admin-ui"
)

# -----------------------------------------------------------------------------
# Parse command line arguments
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            DEPLOY_ALL=true
            shift
            ;;
        --infra|--infrastructure)
            DEPLOY_INFRA=true
            shift
            ;;
        --databases)
            DEPLOY_DBS=true
            shift
            ;;
        --services)
            DEPLOY_SERVICES=true
            shift
            ;;
        --frontends)
            DEPLOY_FRONTENDS=true
            shift
            ;;
        --build)
            BUILD_IMAGES=true
            export BUILD_IMAGES=true
            shift
            ;;
        --dapr)
            DAPR_ENABLED=true
            export DAPR_ENABLED=true
            shift
            ;;
        --clean)
            CLEAN_FIRST=true
            shift
            ;;
        --parallel)
            PARALLEL_DEPLOY=true
            SEQUENTIAL_DEPLOY=false
            shift
            ;;
        --sequential)
            SEQUENTIAL_DEPLOY=true
            PARALLEL_DEPLOY=false
            shift
            ;;
        --seed)
            SEED_DATA=true
            shift
            ;;
        --help|-h)
            head -60 "$0" | grep -E "^#" | sed 's/^# //' | sed 's/^#//'
            exit 0
            ;;
        --auth-service|--user-service|--product-service|--inventory-service|\
        --order-service|--payment-service|--cart-service|--review-service|\
        --admin-service|--notification-service|--audit-service|--chat-service|\
        --order-processor-service|--web-bff|--customer-ui|--admin-ui)
            service_name="${1#--}"  # Remove -- prefix
            SERVICES_TO_DEPLOY[$service_name]=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# If no specific options given, deploy all
if [ "$DEPLOY_ALL" = false ] && [ "$DEPLOY_INFRA" = false ] && \
   [ "$DEPLOY_DBS" = false ] && [ "$DEPLOY_SERVICES" = false ] && \
   [ "$DEPLOY_FRONTENDS" = false ] && [ ${#SERVICES_TO_DEPLOY[@]} -eq 0 ]; then
    DEPLOY_ALL=true
fi

# If deploy all, enable everything
if [ "$DEPLOY_ALL" = true ]; then
    DEPLOY_INFRA=true
    DEPLOY_DBS=true
    DEPLOY_SERVICES=true
    DEPLOY_FRONTENDS=true
fi

# If deploy services flag is set, add all backend services
if [ "$DEPLOY_SERVICES" = true ]; then
    for service in "auth-service" "user-service" "product-service" "inventory-service" \
                   "order-service" "payment-service" "cart-service" "review-service" \
                   "admin-service" "notification-service" "audit-service" "chat-service" \
                   "order-processor-service" "web-bff"; do
        SERVICES_TO_DEPLOY[$service]=true
    done
fi

# If deploy frontends flag is set, add frontend services
if [ "$DEPLOY_FRONTENDS" = true ]; then
    SERVICES_TO_DEPLOY["customer-ui"]=true
    SERVICES_TO_DEPLOY["admin-ui"]=true
fi

# Track deployment progress
SCRIPT_START_TIME=$SECONDS

# -----------------------------------------------------------------------------
# Show deployment plan
# -----------------------------------------------------------------------------
print_header "xshopai Local Docker Deployment"

echo -e "${CYAN}Configuration:${NC}"
echo -e "  Build Images:     ${BUILD_IMAGES}"
echo -e "  Dapr Enabled:     ${DAPR_ENABLED}"
echo -e "  Clean First:      ${CLEAN_FIRST}"
echo -e "  Deploy Infra:     ${DEPLOY_INFRA}"
echo -e "  Deploy Databases: ${DEPLOY_DBS}"
echo -e "  Parallel Deploy:  ${PARALLEL_DEPLOY}"
echo -e "  Seed Data:        ${SEED_DATA}"
echo ""

if [ ${#SERVICES_TO_DEPLOY[@]} -gt 0 ]; then
    echo -e "${CYAN}Services to deploy:${NC}"
    for service in "${!SERVICES_TO_DEPLOY[@]}"; do
        echo -e "  - $service"
    done
    echo ""
fi

# Check Docker
check_docker

# =============================================================================
# Clean up if requested
# =============================================================================
if [ "$CLEAN_FIRST" = true ]; then
    print_header "Cleaning up existing deployment"
    
    # Stop all xshopai containers
    print_step "Stopping all xshopai containers..."
    docker ps -a --filter "name=xshopai-" -q | xargs -r docker stop 2>/dev/null || true
    docker ps -a --filter "name=xshopai-" -q | xargs -r docker rm 2>/dev/null || true
    print_success "Containers removed"
    
    # Remove volumes
    print_step "Removing volumes..."
    docker volume ls --filter "name=xshopai_" -q | xargs -r docker volume rm 2>/dev/null || true
    print_success "Volumes removed"
    
    # Remove network
    cleanup_network
    
    print_success "Cleanup complete"
fi

# =============================================================================
# Deploy Network
# =============================================================================
print_header "Setting up Docker Network"
source "$MODULES_DIR/01-network.sh"

# =============================================================================
# Deploy Infrastructure
# =============================================================================
if [ "$DEPLOY_INFRA" = true ]; then
    print_header "Deploying Infrastructure Services"
    source "$MODULES_DIR/02-infrastructure.sh"
fi

# =============================================================================
# Deploy Databases
# =============================================================================
if [ "$DEPLOY_DBS" = true ]; then
    print_header "Deploying Databases"
    source "$MODULES_DIR/03-mongodb.sh"
    source "$MODULES_DIR/04-postgresql.sh"
    source "$MODULES_DIR/05-sqlserver.sh"
    source "$MODULES_DIR/06-mysql.sh"
fi

# =============================================================================
# Deploy Individual Services
# =============================================================================
if [ ${#SERVICES_TO_DEPLOY[@]} -gt 0 ]; then
    print_header "Deploying Application Services"
    
    if [ "$PARALLEL_DEPLOY" = true ] && [ ${#SERVICES_TO_DEPLOY[@]} -gt 1 ]; then
        echo -e "${CYAN}⚡ Deploying ${#SERVICES_TO_DEPLOY[@]} services in parallel...${NC}"
        echo ""
        
        # Create temp directory for results
        DEPLOY_TEMP_DIR=$(mktemp -d)
        trap "rm -rf $DEPLOY_TEMP_DIR" EXIT
        
        # Track PIDs for parallel processes
        declare -A SERVICE_PIDS
        
        # Start all deployments in parallel
        for service in "${!SERVICES_TO_DEPLOY[@]}"; do
            service_script="$SERVICES_DIR/${service}.sh"
            
            if [ -f "$service_script" ]; then
                (
                    # Redirect output to service-specific log file
                    exec > "$DEPLOY_TEMP_DIR/${service}.log" 2>&1
                    
                    print_subheader "Deploying $service"
                    if source "$service_script"; then
                        echo "SUCCESS" > "$DEPLOY_TEMP_DIR/${service}.status"
                    else
                        echo "FAILED" > "$DEPLOY_TEMP_DIR/${service}.status"
                    fi
                ) &
                SERVICE_PIDS[$service]=$!
                echo -e "  ${YELLOW}→${NC} Started $service (PID: ${SERVICE_PIDS[$service]})"
            else
                echo -e "  ${RED}✗${NC} Service script not found: $service_script"
                echo "FAILED" > "$DEPLOY_TEMP_DIR/${service}.status"
            fi
        done
        
        echo ""
        echo -e "${CYAN}⏳ Waiting for all services to deploy...${NC}"
        
        # Wait for all processes and collect results
        FAILED_SERVICES=()
        SUCCESS_SERVICES=()
        
        for service in "${!SERVICE_PIDS[@]}"; do
            pid=${SERVICE_PIDS[$service]}
            if wait $pid 2>/dev/null; then
                if [ -f "$DEPLOY_TEMP_DIR/${service}.status" ] && [ "$(cat $DEPLOY_TEMP_DIR/${service}.status)" = "SUCCESS" ]; then
                    SUCCESS_SERVICES+=("$service")
                    echo -e "  ${GREEN}✓${NC} $service deployed successfully"
                else
                    FAILED_SERVICES+=("$service")
                    echo -e "  ${RED}✗${NC} $service deployment failed"
                fi
            else
                FAILED_SERVICES+=("$service")
                echo -e "  ${RED}✗${NC} $service deployment failed (process error)"
            fi
        done
        
        echo ""
        
        # Show summary
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}Parallel Deployment Summary${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  ${GREEN}✓ Successful:${NC} ${#SUCCESS_SERVICES[@]}/${#SERVICES_TO_DEPLOY[@]}"
        
        if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
            echo -e "  ${RED}✗ Failed:${NC} ${FAILED_SERVICES[*]}"
            echo ""
            echo -e "${YELLOW}View logs for failed services:${NC}"
            for failed in "${FAILED_SERVICES[@]}"; do
                echo -e "  cat $DEPLOY_TEMP_DIR/${failed}.log"
            done
        fi
        echo ""
        
    else
        # Sequential deployment
        if [ ${#SERVICES_TO_DEPLOY[@]} -gt 1 ]; then
            echo -e "${CYAN}🔄 Deploying services sequentially...${NC}"
            echo ""
        fi
        
        for service in "${!SERVICES_TO_DEPLOY[@]}"; do
            service_script="$SERVICES_DIR/${service}.sh"
            
            if [ -f "$service_script" ]; then
                print_subheader "Deploying $service"
                source "$service_script"
            else
                print_error "Service script not found: $service_script"
            fi
        done
    fi
fi

# =============================================================================
# Seed Demo Data
# =============================================================================
if [ "$SEED_DATA" = true ]; then
    print_header "Seeding Demo Data"
    
    SEED_DIR="$SCRIPT_DIR/../../seed"
    
    if [ -d "$SEED_DIR" ]; then
        print_step "Installing seeder dependencies..."
        pip install -q -r "$SEED_DIR/requirements.txt" 2>/dev/null || {
            print_warning "pip install failed, attempting with pip3..."
            pip3 install -q -r "$SEED_DIR/requirements.txt" 2>/dev/null || {
                print_error "Failed to install seeder dependencies"
                print_error "Run manually: pip install -r deployment/seed/requirements.txt"
            }
        }
        
        print_step "Running seeder..."
        
        # Set database URLs from container networking (with auth credentials)
        export USER_SERVICE_DATABASE_URL="mongodb://admin:admin123@localhost:27018/user_service_db?authSource=admin"
        export PRODUCT_SERVICE_DATABASE_URL="mongodb://admin:admin123@localhost:27019/product_service_db?authSource=admin"
        export INVENTORY_SERVICE_DATABASE_URL="mysql://admin:admin123@localhost:3306/inventory_service_db"
        
        python "$SEED_DIR/seed.py" --clear || python3 "$SEED_DIR/seed.py" --clear || {
            print_error "Seeding failed. Check database connectivity."
        }
        
        print_success "Demo data seeded successfully"
    else
        print_error "Seed directory not found: $SEED_DIR"
    fi
fi

# =============================================================================
# Final Summary
# =============================================================================
TOTAL_TIME=$((SECONDS - SCRIPT_START_TIME))
print_header "Deployment Complete! (${TOTAL_TIME}s)"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                    xshopai Platform is Ready!                               ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Show running containers
echo -e "\n${CYAN}Running xshopai containers:${NC}"
docker ps --filter "name=xshopai-" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  No containers running"

echo -e "\n${CYAN}📱 Frontend Applications:${NC}"
echo -e "  Customer UI:            ${GREEN}http://localhost:3000${NC}"
echo -e "  Admin UI:               ${GREEN}http://localhost:3001${NC}"

echo -e "\n${CYAN}🔌 API Services:${NC}"
echo -e "  Product Service:        ${GREEN}http://localhost:8001${NC}"
echo -e "  User Service:           ${GREEN}http://localhost:8002${NC}"
echo -e "  Admin Service:          ${GREEN}http://localhost:8003${NC}"
echo -e "  Auth Service:           ${GREEN}http://localhost:8004${NC}"
echo -e "  Inventory Service:      ${GREEN}http://localhost:8005${NC}"
echo -e "  Order Service:          ${GREEN}http://localhost:8006${NC}"
echo -e "  Order Processor:        ${GREEN}http://localhost:8007${NC}"
echo -e "  Cart Service:           ${GREEN}http://localhost:8008${NC}"
echo -e "  Payment Service:        ${GREEN}http://localhost:8009${NC}"
echo -e "  Review Service:         ${GREEN}http://localhost:8010${NC}"
echo -e "  Notification Service:   ${GREEN}http://localhost:8011${NC}"
echo -e "  Audit Service:          ${GREEN}http://localhost:8012${NC}"
echo -e "  Chat Service:           ${GREEN}http://localhost:8013${NC}"
echo -e "  Web BFF:                ${GREEN}http://localhost:8014${NC}"

echo -e "\n${CYAN}🛠️ Infrastructure:${NC}"
echo -e "  RabbitMQ Management:    ${GREEN}http://localhost:15672${NC} (admin/admin123)"
echo -e "  Zipkin (Dapr):          ${GREEN}http://localhost:9411${NC}"
echo -e "  Mailpit UI:             ${GREEN}http://localhost:8025${NC}"

echo -e "\n${CYAN}🔗 Dapr Infrastructure:${NC}"
echo -e "  Redis (State Store):    ${GREEN}localhost:6379${NC}"
echo -e "  Zipkin (Tracing):       ${GREEN}http://localhost:9411${NC}"
echo -e "  Placement:              ${GREEN}localhost:6050${NC}"
echo -e "  Scheduler:              ${GREEN}localhost:6060${NC}"

if [ "$DAPR_ENABLED" = true ]; then
    echo -e "\n${CYAN}🔗 Dapr Sidecars:${NC}"
    echo -e "  Dapr sidecars are running alongside services"
    echo -e "  Each service can communicate via Dapr at localhost:3500"
fi

echo -e "\n${CYAN}📊 Useful Commands:${NC}"
echo -e "  View all containers:    ${YELLOW}docker ps --filter 'name=xshopai-'${NC}"
echo -e "  View container logs:    ${YELLOW}docker logs -f xshopai-<service-name>${NC}"
echo -e "  Deploy single service:  ${YELLOW}./deploy.sh --<service-name>${NC}"
echo -e "  Stop all containers:    ${YELLOW}./stop.sh${NC}"
echo -e "  Check status:           ${YELLOW}./status.sh${NC}"

if [ "$SEED_DATA" = true ]; then
    echo -e "\n${CYAN}👤 Demo Credentials:${NC}"
    echo -e "  Customer:    ${GREEN}guest@xshopai.com${NC} / ${GREEN}guest${NC}"
    echo -e "  Admin:       ${GREEN}admin@xshopai.com${NC} / ${GREEN}admin${NC}"
fi

# Calculate and display deployment duration
DEPLOY_END_TIME=$(date +%s)
DEPLOY_DURATION=$((DEPLOY_END_TIME - DEPLOY_START_TIME))
DEPLOY_MINUTES=$((DEPLOY_DURATION / 60))
DEPLOY_SECONDS=$((DEPLOY_DURATION % 60))

if [ $DEPLOY_MINUTES -gt 0 ]; then
    echo -e "\n${CYAN}⏱️  Deployment completed in ${GREEN}${DEPLOY_MINUTES}m ${DEPLOY_SECONDS}s${NC}"
else
    echo -e "\n${CYAN}⏱️  Deployment completed in ${GREEN}${DEPLOY_SECONDS}s${NC}"
fi

print_success "Deployment completed successfully!"
