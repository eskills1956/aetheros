#!/bin/bash
# Aether OS Applications Build Script

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
echo -e "${BLUE}  Building Applications               ${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Create necessary directories
mkdir -p "$AETHEROS_OUT/target/apps"
mkdir -p "$AETHEROS_OUT/logs"

BUILD_LOG="$AETHEROS_OUT/logs/apps-build.log"

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
echo "Applications Build Log - $(date)" > "$BUILD_LOG"
echo "================================" >> "$BUILD_LOG"
echo "" >> "$BUILD_LOG"

#
# Check Flutter installation
#
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        log_error "Please install Flutter: https://flutter.dev/docs/get-started/install"
        return 1
    fi

    local flutter_version=$(flutter --version | head -n1)
    log_info "Flutter version: $flutter_version"
    return 0
}

#
# Build Flutter app
#
build_flutter_app() {
    local app_name=$1
    local app_dir=$2

    log_info "Building Flutter app: $app_name"

    if [ ! -d "$app_dir" ]; then
        log_error "App directory not found: $app_dir"
        return 1
    fi

    if [ ! -f "$app_dir/pubspec.yaml" ]; then
        log_error "No pubspec.yaml found in $app_dir"
        return 1
    fi

    cd "$app_dir"

    # Get dependencies
    log_info "Getting Flutter dependencies for $app_name..."
    flutter pub get >> "$BUILD_LOG" 2>&1

    # Build for Linux (for testing/development)
    # In production, we'd build for the target platform
    log_info "Building $app_name for Linux..."
    flutter build linux --release >> "$BUILD_LOG" 2>&1

    # Copy build output
    local output_dir="$AETHEROS_OUT/target/apps/$app_name"
    mkdir -p "$output_dir"

    if [ -d "build/linux/x64/release/bundle" ]; then
        cp -r build/linux/x64/release/bundle/* "$output_dir/"
        log_success "App $app_name built successfully"
    else
        log_error "Build output not found for $app_name"
        cd "$AETHEROS_TOP"
        return 1
    fi

    cd "$AETHEROS_TOP"
    return 0
}

#
# Build native app (C/C++)
#
build_native_app() {
    local app_name=$1
    local app_dir=$2

    log_info "Building native app: $app_name"

    if [ ! -d "$app_dir" ]; then
        log_error "App directory not found: $app_dir"
        return 1
    fi

    cd "$app_dir"

    if [ -f "CMakeLists.txt" ]; then
        # CMake-based build
        local build_dir="$AETHEROS_OUT/target/apps/$app_name/build"
        mkdir -p "$build_dir"
        cd "$build_dir"

        cmake "$app_dir" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX="$AETHEROS_OUT/target/apps/$app_name" \
            -DCMAKE_C_COMPILER="${CROSS_COMPILE}gcc" \
            -DCMAKE_CXX_COMPILER="${CROSS_COMPILE}g++" \
            >> "$BUILD_LOG" 2>&1

        make -j"$PARALLEL_JOBS" >> "$BUILD_LOG" 2>&1
        make install >> "$BUILD_LOG" 2>&1

        log_success "App $app_name built successfully"
    elif [ -f "Makefile" ]; then
        # Makefile-based build
        make -j"$PARALLEL_JOBS" >> "$BUILD_LOG" 2>&1
        make install DESTDIR="$AETHEROS_OUT/target/apps/$app_name" >> "$BUILD_LOG" 2>&1
        log_success "App $app_name built successfully"
    else
        log_warning "No build system found for $app_name"
    fi

    cd "$AETHEROS_TOP"
    return 0
}

#
# Scan and build all apps
#
build_all_apps() {
    log_info "Scanning for applications..."

    if [ ! -d "$AETHEROS_APPS" ]; then
        log_warning "Apps directory not found: $AETHEROS_APPS"
        log_warning "Creating placeholder directory"
        mkdir -p "$AETHEROS_APPS"
        return 0
    fi

    local built_count=0
    local failed_count=0

    # Build each app
    for app_dir in "$AETHEROS_APPS"/*; do
        if [ -d "$app_dir" ]; then
            local app_name=$(basename "$app_dir")

            # Skip hidden directories
            if [[ $app_name == .* ]]; then
                continue
            fi

            log_info "Found app: $app_name"

            # Determine app type and build
            if [ -f "$app_dir/pubspec.yaml" ]; then
                # Flutter app
                if build_flutter_app "$app_name" "$app_dir"; then
                    ((built_count++))
                else
                    ((failed_count++))
                fi
            elif [ -f "$app_dir/CMakeLists.txt" ] || [ -f "$app_dir/Makefile" ]; then
                # Native app
                if build_native_app "$app_name" "$app_dir"; then
                    ((built_count++))
                else
                    ((failed_count++))
                fi
            else
                log_warning "Unknown app type: $app_name (no build system found)"
            fi

            echo ""
        fi
    done

    log_info "Apps built: $built_count"
    if [ $failed_count -gt 0 ]; then
        log_warning "Apps failed: $failed_count"
    fi

    return 0
}

#
# Package applications
#
package_apps() {
    log_info "Packaging applications..."

    local staging_dir="$AETHEROS_OUT/staging/apps"
    mkdir -p "$staging_dir"

    # Copy all built apps to staging
    if [ -d "$AETHEROS_OUT/target/apps" ]; then
        cp -r "$AETHEROS_OUT/target/apps"/* "$staging_dir/" 2>/dev/null || true
        log_info "Applications packaged to $staging_dir"
    fi

    # Create app manifest
    local manifest="$staging_dir/apps.manifest"
    echo "# Aether OS Applications Manifest" > "$manifest"
    echo "# Generated: $(date)" >> "$manifest"
    echo "" >> "$manifest"

    for app_dir in "$staging_dir"/*; do
        if [ -d "$app_dir" ]; then
            local app_name=$(basename "$app_dir")
            echo "app:$app_name:$(find $app_dir -type f | wc -l) files" >> "$manifest"
        fi
    done

    log_success "Application manifest created: $manifest"

    return 0
}

#
# Main build sequence
#
main() {
    local start_time=$(date +%s)

    log_info "Build Type: $AETHEROS_BUILD_TYPE"
    log_info "Target Architecture: $AETHEROS_TARGET_ARCH"
    log_info "Enable Flutter: $ENABLE_FLUTTER"
    echo ""

    # Check Flutter if enabled
    if [ "$ENABLE_FLUTTER" = "true" ]; then
        if ! check_flutter; then
            log_warning "Flutter not available - Flutter apps will be skipped"
            export ENABLE_FLUTTER=false
        fi
        echo ""
    fi

    # Build all applications
    if ! build_all_apps; then
        log_error "Application build failed"
        exit 1
    fi

    echo ""

    # Package applications
    if ! package_apps; then
        log_error "Application packaging failed"
        exit 1
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}  Applications Build Complete!       ${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "Build time: ${duration}s"
    echo -e "Output: $AETHEROS_OUT/staging/apps"
    echo -e "Log: $BUILD_LOG"
    echo ""

    return 0
}

# Run main
main "$@"
