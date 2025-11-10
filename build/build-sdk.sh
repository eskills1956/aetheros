#!/bin/bash
# Aether OS SDK Build Script

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
echo -e "${BLUE}  Building Aether OS SDK             ${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Create necessary directories
mkdir -p "$AETHEROS_SDK"/{tools,libs,include,templates,docs,examples}
mkdir -p "$AETHEROS_OUT/logs"

BUILD_LOG="$AETHEROS_OUT/logs/sdk-build.log"
SDK_VERSION="$AETHEROS_VERSION"

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
echo "SDK Build Log - $(date)" > "$BUILD_LOG"
echo "================================" >> "$BUILD_LOG"
echo "" >> "$BUILD_LOG"

#
# Copy SDK libraries
#
create_sdk_libraries() {
    log_info "Creating SDK libraries..."

    local sdk_libs="$AETHEROS_SDK/libs"

    # Copy libaether.so
    if [ -f "$AETHEROS_OUT/target/lib/libaether.so" ]; then
        cp "$AETHEROS_OUT/target/lib/libaether.so" "$sdk_libs/"
        log_info "Copied libaether.so"
    else
        log_warning "libaether.so not found - building SDK stub"
    fi

    # Copy other system libraries
    if [ -d "$AETHEROS_OUT/target/lib" ]; then
        find "$AETHEROS_OUT/target/lib" -name "*.so" -exec cp {} "$sdk_libs/" \; 2>/dev/null || true
    fi

    log_success "SDK libraries prepared"
    return 0
}

#
# Create SDK headers
#
create_sdk_headers() {
    log_info "Creating SDK headers..."

    local sdk_include="$AETHEROS_SDK/include"
    mkdir -p "$sdk_include/aetheros"

    # Create main SDK header
    cat > "$sdk_include/aetheros/aether.h" << 'EOF'
/**
 * Aether OS SDK
 * Main header file for Aether OS application development
 */

#ifndef AETHEROS_AETHER_H
#define AETHEROS_AETHER_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Version information
#define AETHEROS_SDK_VERSION_MAJOR 1
#define AETHEROS_SDK_VERSION_MINOR 0
#define AETHEROS_SDK_VERSION_PATCH 0

// System functions
int32_t aether_get_battery(void);
int32_t aether_get_signal(void);
void aether_set_brightness(int32_t level);
void aether_set_volume(int32_t level);
int32_t aether_get_wifi_status(void);
int32_t aether_get_bluetooth_status(void);

// Display functions
typedef struct {
    int32_t width;
    int32_t height;
    int32_t refresh_rate;
    int32_t rotation;
} aether_display_info_t;

int aether_get_display_info(aether_display_info_t *info);
int aether_set_display_rotation(int32_t rotation);

// Power management
typedef enum {
    AETHER_POWER_MODE_NORMAL = 0,
    AETHER_POWER_MODE_POWER_SAVE,
    AETHER_POWER_MODE_ULTRA_POWER_SAVE
} aether_power_mode_t;

int aether_set_power_mode(aether_power_mode_t mode);
aether_power_mode_t aether_get_power_mode(void);

// Notifications
typedef struct {
    const char *title;
    const char *message;
    const char *icon;
    int32_t priority;
} aether_notification_t;

int aether_send_notification(const aether_notification_t *notification);

#ifdef __cplusplus
}
#endif

#endif // AETHEROS_AETHER_H
EOF

    # Create system header
    cat > "$sdk_include/aetheros/system.h" << 'EOF'
/**
 * Aether OS System API
 */

#ifndef AETHEROS_SYSTEM_H
#define AETHEROS_SYSTEM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// System information
typedef struct {
    const char *version;
    const char *codename;
    const char *build_type;
    const char *arch;
} aether_system_info_t;

int aether_get_system_info(aether_system_info_t *info);

// Memory information
typedef struct {
    uint64_t total_ram;
    uint64_t available_ram;
    uint64_t total_storage;
    uint64_t available_storage;
} aether_memory_info_t;

int aether_get_memory_info(aether_memory_info_t *info);

#ifdef __cplusplus
}
#endif

#endif // AETHEROS_SYSTEM_H
EOF

    log_success "SDK headers created"
    return 0
}

#
# Create SDK tools
#
create_sdk_tools() {
    log_info "Creating SDK tools..."

    local sdk_tools="$AETHEROS_SDK/tools"

    # Create aether-build tool
    cat > "$sdk_tools/aether-build" << 'EOF'
#!/bin/bash
# Aether OS Application Build Tool

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Aether OS Build Tool v1.0"
echo ""

APP_DIR="${1:-.}"

if [ ! -f "$APP_DIR/pubspec.yaml" ] && [ ! -f "$APP_DIR/CMakeLists.txt" ]; then
    echo "Error: No valid project found in $APP_DIR"
    echo "Supported project types: Flutter (pubspec.yaml) or CMake (CMakeLists.txt)"
    exit 1
fi

# Build Flutter app
if [ -f "$APP_DIR/pubspec.yaml" ]; then
    echo "Building Flutter application..."
    cd "$APP_DIR"
    flutter pub get
    flutter build linux --release
    echo "Build complete!"
fi

# Build CMake app
if [ -f "$APP_DIR/CMakeLists.txt" ]; then
    echo "Building CMake application..."
    mkdir -p "$APP_DIR/build"
    cd "$APP_DIR/build"
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j$(nproc)
    echo "Build complete!"
fi
EOF

    chmod +x "$sdk_tools/aether-build"

    # Create aether-create tool
    cat > "$sdk_tools/aether-create" << 'EOF'
#!/bin/bash
# Aether OS Application Generator

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Aether OS Application Generator v1.0"
echo ""

if [ $# -lt 2 ]; then
    echo "Usage: aether-create <type> <app-name>"
    echo ""
    echo "Types:"
    echo "  flutter  - Create a Flutter application"
    echo "  native   - Create a native C/C++ application"
    echo ""
    exit 1
fi

TYPE=$1
APP_NAME=$2

case $TYPE in
    flutter)
        echo "Creating Flutter application: $APP_NAME"
        flutter create "$APP_NAME"
        echo ""
        echo "Application created!"
        echo "To build: cd $APP_NAME && aether-build"
        ;;
    native)
        echo "Creating native application: $APP_NAME"
        mkdir -p "$APP_NAME"
        cp -r "$SDK_ROOT/templates/native"/* "$APP_NAME/"
        sed -i "s/{{APP_NAME}}/$APP_NAME/g" "$APP_NAME"/* 2>/dev/null || true
        echo ""
        echo "Application created!"
        echo "To build: cd $APP_NAME && aether-build"
        ;;
    *)
        echo "Error: Unknown type '$TYPE'"
        exit 1
        ;;
esac
EOF

    chmod +x "$sdk_tools/aether-create"

    # Create aether-package tool
    cat > "$sdk_tools/aether-package" << 'EOF'
#!/bin/bash
# Aether OS Application Packager

echo "Aether OS Application Packager v1.0"
echo ""

APP_DIR="${1:-.}"
APP_NAME=$(basename "$APP_DIR")

if [ ! -d "$APP_DIR" ]; then
    echo "Error: Directory not found: $APP_DIR"
    exit 1
fi

echo "Packaging application: $APP_NAME"

# Create package directory
PKG_DIR="/tmp/aether-pkg-$APP_NAME"
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR"

# Copy application files
cp -r "$APP_DIR"/* "$PKG_DIR/"

# Create package archive
tar -czf "$APP_NAME.apk" -C "$(dirname "$PKG_DIR")" "$(basename "$PKG_DIR")"
rm -rf "$PKG_DIR"

echo ""
echo "Package created: $APP_NAME.apk"
EOF

    chmod +x "$sdk_tools/aether-package"

    log_success "SDK tools created"
    return 0
}

#
# Create project templates
#
create_templates() {
    log_info "Creating project templates..."

    local templates_dir="$AETHEROS_SDK/templates"

    # Create native app template
    mkdir -p "$templates_dir/native"

    cat > "$templates_dir/native/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.10)
project({{APP_NAME}})

set(CMAKE_CXX_STANDARD 17)

# Find Aether OS SDK
set(AETHEROS_SDK $ENV{AETHEROS_SDK})
include_directories(${AETHEROS_SDK}/include)
link_directories(${AETHEROS_SDK}/libs)

add_executable({{APP_NAME}} main.cpp)
target_link_libraries({{APP_NAME}} aether)
EOF

    cat > "$templates_dir/native/main.cpp" << 'EOF'
#include <iostream>
#include <aetheros/aether.h>

int main() {
    std::cout << "Hello from Aether OS!" << std::endl;

    // Example: Get battery level
    int32_t battery = aether_get_battery();
    std::cout << "Battery level: " << battery << "%" << std::endl;

    return 0;
}
EOF

    log_success "Project templates created"
    return 0
}

#
# Create SDK documentation
#
create_documentation() {
    log_info "Creating SDK documentation..."

    local docs_dir="$AETHEROS_SDK/docs"

    cat > "$docs_dir/README.md" << 'EOF'
# Aether OS SDK

Welcome to the Aether OS Software Development Kit (SDK)!

## Overview

The Aether OS SDK provides tools, libraries, and documentation for building applications for the Aether OS mobile platform.

## Getting Started

### Setup

1. Set the SDK environment variable:
   ```bash
   export AETHEROS_SDK=/path/to/sdk
   export PATH=$AETHEROS_SDK/tools:$PATH
   ```

2. Create a new application:
   ```bash
   aether-create flutter my-app
   # or
   aether-create native my-app
   ```

3. Build your application:
   ```bash
   cd my-app
   aether-build
   ```

4. Package your application:
   ```bash
   aether-package
   ```

## SDK Structure

- `tools/` - Development tools (aether-build, aether-create, aether-package)
- `libs/` - System libraries (libaether.so, etc.)
- `include/` - Header files for native development
- `templates/` - Project templates
- `docs/` - Documentation
- `examples/` - Example applications

## API Reference

### System APIs

- `aether_get_battery()` - Get battery level (0-100)
- `aether_get_signal()` - Get signal strength (0-4)
- `aether_set_brightness(level)` - Set screen brightness (0-100)
- `aether_set_volume(level)` - Set system volume (0-100)

See `include/aetheros/aether.h` for complete API documentation.

## Flutter Development

Aether OS fully supports Flutter for application development. Use the standard Flutter tools with the Aether OS SDK.

## Native Development

For native C/C++ applications, link against `libaether.so` and include the Aether OS headers.

Example CMakeLists.txt:
```cmake
include_directories(${AETHEROS_SDK}/include)
link_directories(${AETHEROS_SDK}/libs)
target_link_libraries(myapp aether)
```

## Support

For issues and questions, please visit:
https://github.com/aetheros/sdk/issues

## License

Copyright (c) 2024 Aether OS Project
Licensed under the Apache License 2.0
EOF

    log_success "SDK documentation created"
    return 0
}

#
# Create SDK examples
#
create_examples() {
    log_info "Creating SDK examples..."

    local examples_dir="$AETHEROS_SDK/examples"

    # Create hello-world example
    mkdir -p "$examples_dir/hello-world"

    cat > "$examples_dir/hello-world/main.cpp" << 'EOF'
#include <iostream>
#include <aetheros/aether.h>

int main() {
    std::cout << "=== Aether OS Hello World ===" << std::endl;
    std::cout << std::endl;

    // Display system information
    int32_t battery = aether_get_battery();
    int32_t signal = aether_get_signal();

    std::cout << "System Status:" << std::endl;
    std::cout << "  Battery: " << battery << "%" << std::endl;
    std::cout << "  Signal: " << signal << "/4 bars" << std::endl;

    // Send notification
    aether_notification_t notif = {
        .title = "Hello World",
        .message = "Application started successfully!",
        .icon = "info",
        .priority = 0
    };
    aether_send_notification(&notif);

    return 0;
}
EOF

    cat > "$examples_dir/hello-world/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(hello-world)

set(CMAKE_CXX_STANDARD 17)
set(AETHEROS_SDK $ENV{AETHEROS_SDK})

include_directories(${AETHEROS_SDK}/include)
link_directories(${AETHEROS_SDK}/libs)

add_executable(hello-world main.cpp)
target_link_libraries(hello-world aether)
EOF

    cat > "$examples_dir/README.md" << 'EOF'
# Aether OS SDK Examples

This directory contains example applications demonstrating Aether OS SDK features.

## Examples

- `hello-world/` - Basic application using system APIs

## Building Examples

```bash
cd examples/hello-world
aether-build
```
EOF

    log_success "SDK examples created"
    return 0
}

#
# Create SDK package
#
package_sdk() {
    log_info "Packaging SDK..."

    local sdk_package="$AETHEROS_OUT/images/aetheros-sdk-$SDK_VERSION.tar.gz"

    tar -czf "$sdk_package" -C "$(dirname $AETHEROS_SDK)" "$(basename $AETHEROS_SDK)" >> "$BUILD_LOG" 2>&1

    local package_size=$(du -h "$sdk_package" | cut -f1)

    log_success "SDK package created: $sdk_package ($package_size)"
    return 0
}

#
# Main build sequence
#
main() {
    local start_time=$(date +%s)

    log_info "SDK Version: $SDK_VERSION"
    log_info "SDK Location: $AETHEROS_SDK"
    echo ""

    # Create SDK components
    if ! create_sdk_libraries; then
        log_error "Failed to create SDK libraries"
        exit 1
    fi

    echo ""

    if ! create_sdk_headers; then
        log_error "Failed to create SDK headers"
        exit 1
    fi

    echo ""

    if ! create_sdk_tools; then
        log_error "Failed to create SDK tools"
        exit 1
    fi

    echo ""

    if ! create_templates; then
        log_error "Failed to create project templates"
        exit 1
    fi

    echo ""

    if ! create_documentation; then
        log_error "Failed to create SDK documentation"
        exit 1
    fi

    echo ""

    if ! create_examples; then
        log_error "Failed to create SDK examples"
        exit 1
    fi

    echo ""

    if ! package_sdk; then
        log_error "Failed to package SDK"
        exit 1
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}  SDK Build Complete!                ${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "Build time: ${duration}s"
    echo -e "SDK location: $AETHEROS_SDK"
    echo -e "Log: $BUILD_LOG"
    echo ""
    echo -e "${BLUE}To use the SDK:${NC}"
    echo -e "  export AETHEROS_SDK=$AETHEROS_SDK"
    echo -e "  export PATH=\$AETHEROS_SDK/tools:\$PATH"
    echo ""

    return 0
}

# Run main
main "$@"
