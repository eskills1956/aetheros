#!/bin/bash
# Aether OS Boot Initialization Script
# This script runs during early boot to set up the system

set -e

# Boot stage indicator
BOOT_STAGE="init"

# Colors for boot messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_boot() {
    echo -e "${BLUE}[BOOT]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print boot banner
print_banner() {
    cat << 'EOF'
    _         _   _               ___  ____
   / \   ___ | |_| |__   ___ _ __/ _ \/ ___|
  / _ \ / _ \| __| '_ \ / _ \ '__| | | \___ \
 / ___ \  __/| |_| | | |  __/ |  | |_| |___) |
/_/   \_\___| \__|_| |_|\___|_|   \___/|____/

Aether OS v1.0.0 - Aurora
EOF
}

# Mount essential filesystems
mount_filesystems() {
    log_boot "Mounting essential filesystems..."

    mount -t proc proc /proc
    mount -t sysfs sysfs /sys
    mount -t devtmpfs devtmpfs /dev
    mount -t tmpfs tmpfs /tmp
    mount -t tmpfs tmpfs /run

    log_success "Essential filesystems mounted"
}

# Initialize device nodes
init_devices() {
    log_boot "Initializing device nodes..."

    # Create essential device nodes if they don't exist
    [ -e /dev/null ] || mknod -m 666 /dev/null c 1 3
    [ -e /dev/zero ] || mknod -m 666 /dev/zero c 1 5
    [ -e /dev/random ] || mknod -m 444 /dev/random c 1 8
    [ -e /dev/urandom ] || mknod -m 444 /dev/urandom c 1 9

    log_success "Device nodes initialized"
}

# Load kernel modules
load_modules() {
    log_boot "Loading kernel modules..."

    # Load essential modules
    modprobe -a \
        ext4 \
        vfat \
        usb-storage \
        g_serial \
        2>/dev/null || true

    log_success "Kernel modules loaded"
}

# Check and mount root filesystem
mount_root() {
    log_boot "Checking root filesystem..."

    # Check root filesystem (read-only check)
    if [ -b /dev/mmcblk0p2 ]; then
        fsck -n /dev/mmcblk0p2 || log_error "Root filesystem check failed"
        log_success "Root filesystem check completed"
    fi
}

# Set up data partition
setup_data() {
    log_boot "Setting up data partition..."

    if [ -b /dev/mmcblk0p3 ]; then
        mkdir -p /data
        mount /dev/mmcblk0p3 /data 2>/dev/null || log_error "Failed to mount data partition"
        log_success "Data partition mounted"
    fi
}

# Initialize system services
init_services() {
    log_boot "Initializing system services..."

    # Set hostname
    hostname aetheros

    # Set up logging
    mkdir -p /var/log

    # Create runtime directories
    mkdir -p /run/lock /run/user
    chmod 1777 /run/lock

    log_success "System services initialized"
}

# Main boot sequence
main() {
    clear
    print_banner
    echo ""

    log_boot "Starting Aether OS boot sequence..."
    echo ""

    mount_filesystems
    init_devices
    load_modules
    mount_root
    setup_data
    init_services

    echo ""
    log_success "Boot initialization complete"
    echo ""

    # Hand off to systemd or init
    if [ -x /sbin/init ]; then
        exec /sbin/init
    else
        log_error "Init system not found!"
        exec /bin/sh
    fi
}

# Run main
main "$@"
