#!/bin/bash
# Integration tests for Aether OS system services

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Test if services exist
test_service_binaries() {
    log_info "Testing service binaries..."

    local services=(
        "aether-display-service"
        "aether-audio-service"
        "aether-power-service"
        "aether-network-service"
    )

    for service in "${services[@]}"; do
        if [ -f "$AETHEROS_OUT/staging/system/bin/$service" ]; then
            log_success "Service binary exists: $service"
        else
            log_error "Service binary missing: $service"
        fi
    done
}

# Test if libraries exist
test_libraries() {
    log_info "Testing libraries..."

    if [ -f "$AETHEROS_OUT/staging/system/lib/libaether.so" ]; then
        log_success "libaether.so exists"
    else
        log_error "libaether.so missing"
    fi
}

# Test service startup (dry-run)
test_service_help() {
    log_info "Testing service help/version..."

    # Most services should at least respond to --help or --version
    # For now, just check if they're executable
    local services=(
        "aether-display-service"
        "aether-audio-service"
        "aether-power-service"
        "aether-network-service"
    )

    for service in "${services[@]}"; do
        if [ -x "$AETHEROS_OUT/staging/system/bin/$service" ]; then
            log_success "Service is executable: $service"
        else
            log_error "Service not executable: $service"
        fi
    done
}

# Main
echo "=========================================="
echo "  Aether OS Integration Tests"
echo "=========================================="
echo ""

if [ -z "$AETHEROS_OUT" ]; then
    export AETHEROS_OUT="$(cd $(dirname $0)/../.. && pwd)/out"
fi

log_info "Using AETHEROS_OUT: $AETHEROS_OUT"
echo ""

test_service_binaries
echo ""

test_libraries
echo ""

test_service_help
echo ""

echo "=========================================="
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo "=========================================="

exit $TESTS_FAILED
