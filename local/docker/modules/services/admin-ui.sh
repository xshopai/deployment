#!/bin/bash

# =============================================================================
# Admin UI Deployment
# =============================================================================
# Service: admin-ui
# Port: 3001
# Technology: React (served via nginx)
# Backend: admin-service (port 8003)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# =============================================================================
# Service Configuration
# =============================================================================
SERVICE_NAME="admin-ui"
SERVICE_VERSION="1.0.0"
SERVICE_PORT="3001"

# =============================================================================
# Backend Configuration
# =============================================================================
BFF_URL="http://xshopai-web-bff:8014"

# =============================================================================
# Deploy admin-ui
# =============================================================================
deploy_frontend "$SERVICE_NAME" "$SERVICE_PORT" \
    "-e BFF_URL=$BFF_URL"

# Summary
echo -e "\n${CYAN}Admin UI:${NC}"
echo -e "  Application: ${GREEN}http://localhost:${SERVICE_PORT}${NC}"
echo -e "  BFF Backend: ${GREEN}${BFF_URL}${NC}"
