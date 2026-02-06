#!/bin/bash

# =============================================================================
# Traffic Generator for xshopai Services
# Generates HTTP requests to services for distributed tracing in Zipkin
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Service endpoints
CUSTOMER_UI_URL="http://localhost:3000"
ADMIN_UI_URL="http://localhost:3001"
WEB_BFF_URL="http://localhost:8014"
AUTH_URL="http://localhost:8004"
USER_URL="http://localhost:8002"
PRODUCT_URL="http://localhost:8001"
INVENTORY_URL="http://localhost:8005"
CART_URL="http://localhost:8008"
ORDER_URL="http://localhost:8006"
PAYMENT_URL="http://localhost:8009"
REVIEW_URL="http://localhost:8010"
ADMIN_URL="http://localhost:8003"
NOTIFICATION_URL="http://localhost:8011"
AUDIT_URL="http://localhost:8012"
CHAT_URL="http://localhost:8013"
ZIPKIN_URL="http://localhost:9412"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}                    xshopai Traffic Generator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Generating traffic to all services...${NC}"
echo ""
echo -e "${YELLOW}View traces at:${NC} ${GREEN}$ZIPKIN_URL${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to make request and show result
make_request() {
    local service="$1"
    local method="$2"
    local endpoint="$3"
    local description="$4"
    
    echo -e "  ${BLUE}→${NC} $description"
    
    response=$(curl -s -w "\n%{http_code}" -X "$method" "$endpoint" \
        -H "Content-Type: application/json" \
        -H "x-correlation-id: traffic-gen-$(date +%s%N)")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "    ${GREEN}✓${NC} HTTP $http_code"
    else
        echo -e "    ${YELLOW}!${NC} HTTP $http_code"
    fi
    
    sleep 0.5  # Small delay between requests
}

# =============================================================================
# Frontend Traffic (Customer UI & Admin UI)
# =============================================================================
echo -e "${YELLOW}Frontend Requests:${NC}"
echo ""

make_request "customer-ui" "GET" "$CUSTOMER_UI_URL/" "Customer UI Homepage"
make_request "customer-ui" "GET" "$CUSTOMER_UI_URL/api/storefront/home?productsLimit=4&categoriesLimit=5" "Customer UI - Storefront API"
make_request "admin-ui" "GET" "$ADMIN_UI_URL/" "Admin UI Homepage"
make_request "admin-ui" "GET" "$ADMIN_UI_URL/api/health" "Admin UI - Health via BFF"

echo ""

# =============================================================================
# Web BFF Traffic
# =============================================================================
echo -e "${YELLOW}Web BFF Requests:${NC}"
echo ""

make_request "web-bff" "GET" "$WEB_BFF_URL/health" "Health check"
make_request "web-bff" "GET" "$WEB_BFF_URL/api/storefront/home?productsLimit=4&categoriesLimit=5" "Storefront home"
make_request "web-bff" "GET" "$WEB_BFF_URL/api/products/trending?limit=10" "Trending products"

echo ""

# =============================================================================
# Auth Service Traffic
# =============================================================================
echo -e "${YELLOW}Auth Service Requests:${NC}"
echo ""

make_request "auth" "GET" "$AUTH_URL/health" "Health check"
make_request "auth" "GET" "$AUTH_URL/health/ready" "Readiness check"

echo ""

# =============================================================================
# User Service Traffic
# =============================================================================
echo -e "${YELLOW}User Service Requests:${NC}"
echo ""

make_request "user" "GET" "$USER_URL/health" "Health check"
make_request "user" "GET" "$USER_URL/health/ready" "Readiness check"

echo ""

# =============================================================================
# Product Service Traffic
# =============================================================================
echo -e "${YELLOW}Product Service Requests:${NC}"
echo ""

make_request "product" "GET" "$PRODUCT_URL/health" "Health check"
make_request "product" "GET" "$PRODUCT_URL/health/ready" "Readiness check"
make_request "product" "GET" "$PRODUCT_URL/api/products?page=1&limit=10" "List products (page 1)"
make_request "product" "GET" "$PRODUCT_URL/api/products?page=2&limit=10" "List products (page 2)"
make_request "product" "GET" "$PRODUCT_URL/api/products/search?q=laptop" "Search products (laptop)"

echo ""

# =============================================================================
# Inventory Service Traffic
# =============================================================================
echo -e "${YELLOW}Inventory Service Requests:${NC}"
echo ""

make_request "inventory" "GET" "$INVENTORY_URL/health" "Health check"
make_request "inventory" "GET" "$INVENTORY_URL/health/ready" "Readiness check"
make_request "inventory" "GET" "$INVENTORY_URL/api/inventory?page=1&limit=10" "List inventory items"
make_request "inventory" "GET" "$INVENTORY_URL/api/inventory/low-stock?threshold=10" "Get low stock items"
make_request "inventory" "GET" "$INVENTORY_URL/metrics" "Get metrics"

echo ""

# =============================================================================
# Cart Service Traffic
# =============================================================================
echo -e "${YELLOW}Cart Service Requests:${NC}"
echo ""

make_request "cart" "GET" "$CART_URL/health" "Health check"

echo ""

# =============================================================================
# Order Service Traffic
# =============================================================================
echo -e "${YELLOW}Order Service Requests:${NC}"
echo ""

make_request "order" "GET" "$ORDER_URL/health" "Health check"

echo ""

# =============================================================================
# Payment Service Traffic
# =============================================================================
echo -e "${YELLOW}Payment Service Requests:${NC}"
echo ""

make_request "payment" "GET" "$PAYMENT_URL/health" "Health check"

echo ""

# =============================================================================
# Review Service Traffic
# =============================================================================
echo -e "${YELLOW}Review Service Requests:${NC}"
echo ""

make_request "review" "GET" "$REVIEW_URL/health" "Health check"
make_request "review" "GET" "$REVIEW_URL/health/ready" "Readiness check"

echo ""

# =============================================================================
# Admin Service Traffic
# =============================================================================
echo -e "${YELLOW}Admin Service Requests:${NC}"
echo ""

make_request "admin" "GET" "$ADMIN_URL/health" "Health check"

echo ""

# =============================================================================
# Notification Service Traffic
# =============================================================================
echo -e "${YELLOW}Notification Service Requests:${NC}"
echo ""

make_request "notification" "GET" "$NOTIFICATION_URL/health" "Health check"
make_request "notification" "GET" "$NOTIFICATION_URL/health/ready" "Readiness check"
make_request "notification" "GET" "$NOTIFICATION_URL/metrics" "Get metrics"

echo ""

# =============================================================================
# Audit Service Traffic
# =============================================================================
echo -e "${YELLOW}Audit Service Requests:${NC}"
echo ""

make_request "audit" "GET" "$AUDIT_URL/health" "Health check"

echo ""

# =============================================================================
# Chat Service Traffic
# =============================================================================
echo -e "${YELLOW}Chat Service Requests:${NC}"
echo ""

make_request "chat" "GET" "$CHAT_URL/health" "Health check"

echo ""
make_request "product" "GET" "$PRODUCT_URL/api/products/trending?category=all&limit=5" "Get trending products"

# Metrics
make_request "product" "GET" "$PRODUCT_URL/metrics" "Get metrics"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓${NC} Traffic generation complete!"
echo ""
echo -e "${YELLOW}View distributed traces:${NC}"
echo -e "  Zipkin UI: ${GREEN}$ZIPKIN_URL${NC}"
echo ""
echo -e "${YELLOW}Trace search tips:${NC}"
echo -e "  • Service Name: ${GREEN}inventory-service${NC} or ${GREEN}product-service${NC}"
echo -e "  • Look for traces with tag: ${GREEN}http.url${NC}"
echo -e "  • Filter by duration or error status"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
