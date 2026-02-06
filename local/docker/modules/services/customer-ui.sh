#!/bin/bash

# =============================================================================
# Customer UI Deployment
# =============================================================================
# Service: customer-ui
# Port: 3000
# Technology: React (served via nginx)
# Backend: web-bff (port 8014)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="customer-ui"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="3000"

# =============================================================================
# Backend Configuration
# =============================================================================
BFF_URL="http://xshopai-web-bff:8014"

# =============================================================================
# Deploy customer-ui
# =============================================================================
deploy_frontend "$SERVICE_NAME" "$SERVICE_PORT" \
    "-e BFF_URL=$BFF_URL"

# Summary
echo -e "\n${CYAN}Customer UI:${NC}"
echo -e "  Application:  ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  BFF Backend:  ${GREEN}http://localhost:8014${NC}"
