#!/bin/bash
# Aether OS Build Environment Setup Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine project root
if [ -z "$AETHEROS_TOP" ]; then
    export AETHEROS_TOP=$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)
fi

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Aether OS Build Environment Setup  ${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Set up environment variables
export AETHEROS_VERSION="1.0.0"
export AETHEROS_CODENAME="Aurora"
export AETHEROS_BUILD_TYPE="${AETHEROS_BUILD_TYPE:-eng}"
export AETHEROS_TARGET_ARCH="${AETHEROS_TARGET_ARCH:-arm64}"

# Directory paths
export AETHEROS_SRC="$AETHEROS_TOP/src"
export AETHEROS_OUT="$AETHEROS_TOP/out"
export AETHEROS_BUILD="$AETHEROS_TOP/build"
export AETHEROS_TOOLS="$AETHEROS_TOP/tools"
export AETHEROS_DEVICE="$AETHEROS_TOP/device"
export AETHEROS_SDK="$AETHEROS_TOP/sdk"

# Component paths
export AETHEROS_KERNEL="$AETHEROS_SRC/kernel"
export AETHEROS_COMPOSITOR="$AETHEROS_SRC/compositor"
export AETHEROS_APPS="$AETHEROS_SRC/apps"
export AETHEROS_SYSTEM="$AETHEROS_SRC/system"

# Build configuration
export PARALLEL_JOBS="${PARALLEL_JOBS:-$(nproc)}"
export USE_CCACHE="${USE_CCACHE:-true}"

# Feature flags (from aetheros.config)
export ENABLE_FLUTTER=true
export ENABLE_WAYLAND=true
export ENABLE_PIPEWIRE=true
export ENABLE_SYSTEMD=true
export ENABLE_NETWORKMANAGER=true
export ENABLE_SELINUX=true
export ENABLE_VERIFIED_BOOT=true

# Add tools to PATH
export PATH="$AETHEROS_TOOLS/debugging:$AETHEROS_TOOLS/flashing:$PATH"
export PATH="$AETHEROS_OUT/host/bin:$PATH"

# Create output directories
mkdir -p "$AETHEROS_OUT"/{target,host,logs,staging,images}
mkdir -p "$AETHEROS_SDK"

# Cross-compilation setup
if [ "$AETHEROS_TARGET_ARCH" = "arm64" ]; then
    export CROSS_COMPILE=aarch64-linux-gnu-
    export ARCH=arm64
    export TARGET_TRIPLET=aarch64-linux-gnu
elif [ "$AETHEROS_TARGET_ARCH" = "x86_64" ]; then
    export CROSS_COMPILE=""
    export ARCH=x86_64
    export TARGET_TRIPLET=x86_64-linux-gnu
fi

# Lunch function - Select build target and configuration
function lunch() {
    if [ $# -eq 0 ]; then
        echo -e "${YELLOW}Available targets:${NC}"
        echo "  1. aetheros_arm64-eng     (ARM64 Engineering build)"
        echo "  2. aetheros_arm64-user    (ARM64 User/Production build)"
        echo "  3. aetheros_arm64-userdebug (ARM64 User-Debug build)"
        echo "  4. aetheros_x86_64-eng    (x86_64 Engineering build)"
        echo ""
        echo "Usage: lunch <target>"
        return 1
    fi

    local target=$1
    local arch=$(echo $target | cut -d'-' -f1 | cut -d'_' -f2)
    local buildtype=$(echo $target | cut -d'-' -f2)

    case $arch in
        arm64)
            export AETHEROS_TARGET_ARCH="arm64"
            export CROSS_COMPILE=aarch64-linux-gnu-
            export ARCH=arm64
            export TARGET_TRIPLET=aarch64-linux-gnu
            ;;
        x86_64|x86)
            export AETHEROS_TARGET_ARCH="x86_64"
            export CROSS_COMPILE=""
            export ARCH=x86_64
            export TARGET_TRIPLET=x86_64-linux-gnu
            ;;
        *)
            echo -e "${RED}Error: Unknown architecture '$arch'${NC}"
            return 1
            ;;
    esac

    case $buildtype in
        eng|user|userdebug)
            export AETHEROS_BUILD_TYPE="$buildtype"
            ;;
        *)
            echo -e "${RED}Error: Unknown build type '$buildtype'${NC}"
            return 1
            ;;
    esac

    export AETHEROS_TARGET="$target"

    echo -e "${GREEN}Build target set:${NC}"
    echo "  Target: $AETHEROS_TARGET"
    echo "  Architecture: $AETHEROS_TARGET_ARCH"
    echo "  Build Type: $AETHEROS_BUILD_TYPE"
    echo ""
}

# Helper function to flash the device
function aether-flash() {
    if [ ! -f "$AETHEROS_OUT/images/aetheros-system.img" ]; then
        echo -e "${RED}Error: System image not found. Please build first.${NC}"
        return 1
    fi

    "$AETHEROS_TOOLS/flashing/flash.sh" "$@"
}

# Helper function to clean build
function aether-clean() {
    echo -e "${YELLOW}Cleaning build output...${NC}"
    rm -rf "$AETHEROS_OUT"/*
    echo -e "${GREEN}Clean complete!${NC}"
}

# Helper function to rebuild everything
function aether-rebuild() {
    aether-clean
    make -C "$AETHEROS_TOP" all -j"$PARALLEL_JOBS"
}

# Helper function to show build status
function aether-status() {
    echo -e "${BLUE}Aether OS Build Status${NC}"
    echo -e "${BLUE}======================${NC}"
    echo ""
    echo "Project Root: $AETHEROS_TOP"
    echo "Target: ${AETHEROS_TARGET:-<not set - run 'lunch'>}"
    echo "Architecture: $AETHEROS_TARGET_ARCH"
    echo "Build Type: $AETHEROS_BUILD_TYPE"
    echo "Version: $AETHEROS_VERSION ($AETHEROS_CODENAME)"
    echo "Parallel Jobs: $PARALLEL_JOBS"
    echo ""

    # Check for built components
    echo -e "${BLUE}Built Components:${NC}"
    [ -f "$AETHEROS_OUT/target/kernel/Image" ] && echo -e "  ${GREEN}✓${NC} Kernel" || echo -e "  ${RED}✗${NC} Kernel"
    [ -f "$AETHEROS_OUT/target/compositor/aether-compositor" ] && echo -e "  ${GREEN}✓${NC} Compositor" || echo -e "  ${RED}✗${NC} Compositor"
    [ -d "$AETHEROS_OUT/target/apps/launcher" ] && echo -e "  ${GREEN}✓${NC} Launcher App" || echo -e "  ${RED}✗${NC} Launcher App"
    [ -f "$AETHEROS_OUT/images/aetheros-system.img" ] && echo -e "  ${GREEN}✓${NC} System Image" || echo -e "  ${RED}✗${NC} System Image"
    echo ""
}

# Helper function to enter build shell with environment
function aether-shell() {
    echo -e "${GREEN}Entering Aether OS build shell...${NC}"
    echo "Type 'exit' to leave the build shell"
    $SHELL
}

# Check for required tools
function check_tools() {
    local missing=0

    echo -e "${BLUE}Checking for required tools...${NC}"

    local tools=("make" "gcc" "cmake" "git" "python3")

    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo -e "  ${RED}✗${NC} $tool - not found"
            missing=1
        else
            echo -e "  ${GREEN}✓${NC} $tool"
        fi
    done

    # Check for cross-compiler if building for ARM64
    if [ "$AETHEROS_TARGET_ARCH" = "arm64" ]; then
        if ! command -v aarch64-linux-gnu-gcc &> /dev/null; then
            echo -e "  ${RED}✗${NC} aarch64-linux-gnu-gcc - not found"
            missing=1
        else
            echo -e "  ${GREEN}✓${NC} aarch64-linux-gnu-gcc"
        fi
    fi

    echo ""

    if [ $missing -eq 1 ]; then
        echo -e "${YELLOW}Warning: Some required tools are missing.${NC}"
        echo "Please install missing tools before building."
        echo ""
    fi
}

# Run checks
check_tools

# Print summary
echo -e "${GREEN}Environment ready!${NC}"
echo ""
echo "Available commands:"
echo "  lunch <target>     - Select build target"
echo "  make aetheros      - Build the complete system"
echo "  make kernel        - Build kernel only"
echo "  make system        - Build system components"
echo "  make apps          - Build applications"
echo "  make image         - Create system image"
echo "  aether-flash       - Flash device"
echo "  aether-status      - Show build status"
echo "  aether-clean       - Clean build output"
echo "  aether-rebuild     - Clean and rebuild everything"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Run 'lunch' to select a build target"
echo "  2. Run 'make aetheros -j\$(nproc)' to build"
echo ""
