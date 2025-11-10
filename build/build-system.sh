#!/bin/bash
# Aether OS System Components Build Script

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Source environment if not already set
if [ -z "$AETHEROS_TOP" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/envsetup.sh"
fi

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Building System Components          ${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Create necessary directories
mkdir -p "$AETHEROS_OUT/target/compositor"
mkdir -p "$AETHEROS_OUT/target/system"
mkdir -p "$AETHEROS_OUT/logs"

BUILD_LOG="$AETHEROS_OUT/logs/system-build.log"

# Function to log and print
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$BUILD_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$BUILD_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$BUILD_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$BUILD_LOG"
}

# Initialize log
echo "System Build Log - $(date)" > "$BUILD_LOG"
echo "================================" >> "$BUILD_LOG"
echo "" >> "$BUILD_LOG"

#
# Build Wayland Compositor
#
build_compositor() {
    log_info "Building Wayland Compositor..."

    if [ ! -d "$AETHEROS_COMPOSITOR" ]; then
        log_error "Compositor source directory not found: $AETHEROS_COMPOSITOR"
        return 1
    fi

    # Check for CMakeLists.txt
    if [ ! -f "$AETHEROS_COMPOSITOR/CMakeLists.txt" ]; then
        log_warning "No CMakeLists.txt found in compositor directory"
        log_warning "Skipping compositor build"
        return 0
    fi

    local build_dir="$AETHEROS_OUT/target/compositor/build"
    mkdir -p "$build_dir"

    cd "$build_dir"

    # Configure with CMake
    log_info "Configuring compositor with CMake..."
    cmake "$AETHEROS_COMPOSITOR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$AETHEROS_OUT/target/compositor" \
        -DCMAKE_C_COMPILER="${CROSS_COMPILE}gcc" \
        -DCMAKE_CXX_COMPILER="${CROSS_COMPILE}g++" \
        >> "$BUILD_LOG" 2>&1

    # Build
    log_info "Building compositor..."
    make -j"$PARALLEL_JOBS" >> "$BUILD_LOG" 2>&1

    # Install to staging
    log_info "Installing compositor..."
    make install >> "$BUILD_LOG" 2>&1

    cd "$AETHEROS_TOP"

    log_success "Compositor built successfully"
    return 0
}

#
# Build System Services
#
build_system_services() {
    log_info "Building system services..."

    local system_dir="$AETHEROS_SYSTEM"

    if [ ! -d "$system_dir" ]; then
        log_warning "System services directory not found: $system_dir"
        log_warning "Creating placeholder directory"
        mkdir -p "$system_dir"
        return 0
    fi

    # Check if there are any services to build
    if [ -z "$(ls -A $system_dir)" ]; then
        log_warning "No system services found to build"
        return 0
    fi

    # Build each service
    for service_dir in "$system_dir"/*; do
        if [ -d "$service_dir" ]; then
            local service_name=$(basename "$service_dir")
            log_info "Building service: $service_name"

            if [ -f "$service_dir/Makefile" ]; then
                make -C "$service_dir" -j"$PARALLEL_JOBS" >> "$BUILD_LOG" 2>&1
                log_success "Service $service_name built successfully"
            elif [ -f "$service_dir/CMakeLists.txt" ]; then
                local build_dir="$AETHEROS_OUT/target/system/$service_name/build"
                mkdir -p "$build_dir"
                cd "$build_dir"
                cmake "$service_dir" -DCMAKE_BUILD_TYPE=Release >> "$BUILD_LOG" 2>&1
                make -j"$PARALLEL_JOBS" >> "$BUILD_LOG" 2>&1
                cd "$AETHEROS_TOP"
                log_success "Service $service_name built successfully"
            else
                log_warning "No build system found for service: $service_name"
            fi
        fi
    done

    return 0
}

#
# Build native libraries
#
build_native_libs() {
    log_info "Building native libraries..."

    local lib_dir="$AETHEROS_OUT/target/lib"
    mkdir -p "$lib_dir"

    # Build libaether.so - Native bindings for Flutter
    log_info "Building libaether.so..."

    local libaether_src="$AETHEROS_SRC/frameworks/flutter/libaether"

    if [ ! -d "$libaether_src" ]; then
        log_error "libaether source directory not found: $libaether_src"
        return 1
    fi

    # Check for CMakeLists.txt
    if [ ! -f "$libaether_src/CMakeLists.txt" ]; then
        log_error "No CMakeLists.txt found in libaether directory"
        return 1
    fi

    local build_dir="$AETHEROS_OUT/target/frameworks/libaether/build"
    mkdir -p "$build_dir"

    cd "$build_dir"

    # Configure with CMake
    log_info "Configuring libaether with CMake..."
    cmake "$libaether_src" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$AETHEROS_OUT/target/frameworks/libaether" \
        -DCMAKE_C_COMPILER="${CROSS_COMPILE}gcc" \
        -DCMAKE_CXX_COMPILER="${CROSS_COMPILE}g++" \
        >> "$BUILD_LOG" 2>&1

    # Build
    log_info "Building libaether..."
    make -j"$PARALLEL_JOBS" >> "$BUILD_LOG" 2>&1

    # Install to staging
    log_info "Installing libaether..."
    make install >> "$BUILD_LOG" 2>&1

    # Copy to lib directory for packaging
    cp "$AETHEROS_OUT/target/frameworks/libaether/lib/libaether.so"* "$lib_dir/" 2>/dev/null || true

    cd "$AETHEROS_TOP"

    log_success "libaether.so built successfully"

    return 0
}

#
# Package system components
#
package_system() {
    log_info "Packaging system components..."

    local staging_dir="$AETHEROS_OUT/staging/system"
    mkdir -p "$staging_dir"/{bin,lib,etc,share}

    # Copy compositor
    if [ -f "$AETHEROS_OUT/target/compositor/bin/aether-compositor" ]; then
        cp "$AETHEROS_OUT/target/compositor/bin/aether-compositor" "$staging_dir/bin/"
        log_info "Packaged compositor"
    fi

    # Copy libraries
    if [ -d "$AETHEROS_OUT/target/lib" ]; then
        cp -r "$AETHEROS_OUT/target/lib"/* "$staging_dir/lib/" 2>/dev/null || true
        log_info "Packaged libraries"
    fi

    # Copy system services
    if [ -d "$AETHEROS_OUT/target/system" ]; then
        find "$AETHEROS_OUT/target/system" -type f -executable -exec cp {} "$staging_dir/bin/" \; 2>/dev/null || true
        log_info "Packaged system services"
    fi

    log_success "System components packaged to $staging_dir"

    return 0
}

#
# Main build sequence
#
main() {
    local start_time=$(date +%s)

    log_info "Build Type: $AETHEROS_BUILD_TYPE"
    log_info "Target Architecture: $AETHEROS_TARGET_ARCH"
    log_info "Parallel Jobs: $PARALLEL_JOBS"
    echo ""

    # Build components
    if ! build_compositor; then
        log_error "Compositor build failed"
        exit 1
    fi

    echo ""

    if ! build_system_services; then
        log_error "System services build failed"
        exit 1
    fi

    echo ""

    if ! build_native_libs; then
        log_error "Native libraries build failed"
        exit 1
    fi

    echo ""

    if ! package_system; then
        log_error "System packaging failed"
        exit 1
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}  System Build Complete!             ${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "Build time: ${duration}s"
    echo -e "Output: $AETHEROS_OUT/staging/system"
    echo -e "Log: $BUILD_LOG"
    echo ""

    return 0
}

# Run main
main "$@"
