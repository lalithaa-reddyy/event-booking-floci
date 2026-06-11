#!/bin/bash
set -e

# Build Frontend - Install dependencies and build React app
# This script prepares the React frontend for deployment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

log_header() {
  echo ""
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""
}

# Configuration
FLOCI_ENDPOINT="http://localhost:4566"
STACK_NAME="event-booking-platform"
REGION="us-east-1"

# Source environment if available
if [ -f "$PROJECT_ROOT/.env.floci" ]; then
  source "$PROJECT_ROOT/.env.floci"
fi

# Main execution
log_header "FRONTEND BUILD"

# Navigate to frontend directory
cd "$PROJECT_ROOT/frontend"
log_info "Working directory: $(pwd)"

# Check Node.js
log_info "Checking Node.js..."
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
log_info "✓ Node.js $NODE_VERSION, npm $NPM_VERSION"

# Install dependencies
log_info "Installing npm dependencies..."
if npm install 2>&1 | tail -20; then
  log_info "✓ Dependencies installed"
else
  log_error "Failed to install dependencies"
fi

# Get stack outputs if not already set
if [ -z "$USER_POOL_ID" ]; then
  log_info "Retrieving stack outputs..."
  export AWS_ENDPOINT_URL=$FLOCI_ENDPOINT
  export AWS_ACCESS_KEY_ID=test
  export AWS_SECRET_ACCESS_KEY=test
  export AWS_DEFAULT_REGION=$REGION

  OUTPUTS=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --endpoint-url "$FLOCI_ENDPOINT" \
    --query "Stacks[0].Outputs" 2>/dev/null || echo "[]")

  USER_POOL_ID=$(echo "$OUTPUTS" | grep -o '"OutputKey":"UserPoolId".*"OutputValue":"[^"]*"' | grep -o '"OutputValue":"[^"]*"' | cut -d'"' -f4)
  CLIENT_ID=$(echo "$OUTPUTS" | grep -o '"OutputKey":"UserPoolClientId".*"OutputValue":"[^"]*"' | grep -o '"OutputValue":"[^"]*"' | cut -d'"' -f4)
  API_ENDPOINT=$(echo "$OUTPUTS" | grep -o '"OutputKey":"ApiEndpoint".*"OutputValue":"[^"]*"' | grep -o '"OutputValue":"[^"]*"' | cut -d'"' -f4)
fi

# Create .env file for frontend
log_info "Creating .env file with Floci configuration..."
cat > .env << EOF
REACT_APP_COGNITO_USER_POOL_ID=$USER_POOL_ID
REACT_APP_COGNITO_CLIENT_ID=$CLIENT_ID
REACT_APP_API_ENDPOINT=$API_ENDPOINT
REACT_APP_COGNITO_REGION=$REGION
REACT_APP_DEBUG=false
EOF

log_info "✓ .env file created"
echo "  User Pool ID: $USER_POOL_ID"
echo "  Client ID: $CLIENT_ID"
echo "  API Endpoint: $API_ENDPOINT"

# Build React application
log_info "Building React application for production..."
if npm run build 2>&1 | tail -20; then
  log_info "✓ React build completed successfully"
else
  log_error "React build failed"
fi

# Verify build output
if [ -d "build" ] && [ -f "build/index.html" ]; then
  BUILD_SIZE=$(du -sh build | cut -f1)
  FILE_COUNT=$(find build -type f | wc -l)
  log_info "✓ Build output verified"
  echo "  Size: $BUILD_SIZE"
  echo "  Files: $FILE_COUNT"
else
  log_error "Build output not found"
fi

# Summary
log_header "FRONTEND BUILD COMPLETE"

echo "Frontend is ready for deployment!"
echo ""
echo "Build directory: $(pwd)/build"
echo "Build size: $(du -sh build | cut -f1)"
echo ""
echo "Next steps:"
echo "  1. Deploy to S3: bash scripts/deploy-frontend.sh"
echo "  2. Start dev server: bash scripts/start-frontend.sh"
echo ""
echo "Or continue with full pipeline:"
echo "  bash scripts/full-pipeline.sh"
echo ""

log_info "Frontend build complete!"
