#!/bin/bash
# Aether OS System Image Creation Script

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
echo -e "${BLUE}  Creating System Image               ${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Create necessary directories
mkdir -p "$AETHEROS_OUT/images"
mkdir -p "$AETHEROS_OUT/rootfs"
mkdir -p "$AETHEROS_OUT/logs"

BUILD_LOG="$AETHEROS_OUT/logs/image-build.log"
IMAGE_NAME="aetheros-$AETHEROS_VERSION-$AETHEROS_TARGET_ARCH-$AETHEROS_BUILD_TYPE"
IMAGE_PATH="$AETHEROS_OUT/images/$IMAGE_NAME.img"

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
echo "System Image Creation Log - $(date)" > "$BUILD_LOG"
echo "================================" >> "$BUILD_LOG"
echo "" >> "$BUILD_LOG"

#
# Create root filesystem structure
#
create_rootfs_structure() {
    log_info "Creating root filesystem structure..."

    local rootfs="$AETHEROS_OUT/rootfs"

    # Create standard Linux directory structure
    mkdir -p "$rootfs"/{bin,sbin,etc,proc,sys,dev,tmp,var,run}
    mkdir -p "$rootfs"/usr/{bin,sbin,lib,share,local}
    mkdir -p "$rootfs"/home
    mkdir -p "$rootfs"/root
    mkdir -p "$rootfs"/opt
    mkdir -p "$rootfs"/mnt
    mkdir -p "$rootfs"/media

    # Aether OS specific directories
    mkdir -p "$rootfs"/system/{bin,lib,etc,framework,apps}
    mkdir -p "$rootfs"/data/{app,data,local}
    mkdir -p "$rootfs"/cache

    # Set permissions
    chmod 755 "$rootfs"
    chmod 1777 "$rootfs/tmp"
    chmod 700 "$rootfs/root"

    log_success "Root filesystem structure created"
    return 0
}

#
# Copy kernel
#
install_kernel() {
    log_info "Installing kernel..."

    local kernel_image="$AETHEROS_OUT/target/kernel/Image"
    local rootfs="$AETHEROS_OUT/rootfs"

    if [ -f "$kernel_image" ]; then
        mkdir -p "$rootfs/boot"
        cp "$kernel_image" "$rootfs/boot/Image"
        log_success "Kernel installed"
    else
        log_warning "Kernel image not found at $kernel_image"
        log_warning "You may need to build the kernel first: make kernel"
    fi

    return 0
}

#
# Install system components
#
install_system() {
    log_info "Installing system components..."

    local staging="$AETHEROS_OUT/staging/system"
    local rootfs="$AETHEROS_OUT/rootfs"

    if [ ! -d "$staging" ]; then
        log_warning "System staging directory not found: $staging"
        log_warning "Run 'make system' first"
        return 0
    fi

    # Copy binaries
    if [ -d "$staging/bin" ]; then
        cp -r "$staging/bin"/* "$rootfs/system/bin/" 2>/dev/null || true
        log_info "Installed system binaries"
    fi

    # Copy libraries
    if [ -d "$staging/lib" ]; then
        cp -r "$staging/lib"/* "$rootfs/system/lib/" 2>/dev/null || true
        log_info "Installed system libraries"
    fi

    # Copy configuration files
    if [ -d "$staging/etc" ]; then
        cp -r "$staging/etc"/* "$rootfs/system/etc/" 2>/dev/null || true
        log_info "Installed system configuration"
    fi

    log_success "System components installed"
    return 0
}

#
# Install applications
#
install_apps() {
    log_info "Installing applications..."

    local staging="$AETHEROS_OUT/staging/apps"
    local rootfs="$AETHEROS_OUT/rootfs"

    if [ ! -d "$staging" ]; then
        log_warning "Apps staging directory not found: $staging"
        log_warning "Run 'make apps' first"
        return 0
    fi

    # Copy all apps
    cp -r "$staging"/* "$rootfs/system/apps/" 2>/dev/null || true

    # Count installed apps
    local app_count=$(find "$rootfs/system/apps" -mindepth 1 -maxdepth 1 -type d | wc -l)
    log_info "Installed $app_count applications"

    log_success "Applications installed"
    return 0
}

#
# Create system configuration
#
create_system_config() {
    log_info "Creating system configuration..."

    local rootfs="$AETHEROS_OUT/rootfs"

    # Create fstab
    cat > "$rootfs/etc/fstab" << EOF
# Aether OS filesystem table
# <device>  <mount point>  <type>  <options>  <dump>  <pass>
proc        /proc          proc    defaults   0       0
sysfs       /sys           sysfs   defaults   0       0
devpts      /dev/pts       devpts  gid=5,mode=620  0  0
tmpfs       /run           tmpfs   defaults   0       0
tmpfs       /tmp           tmpfs   defaults   0       0
EOF

    # Create hostname
    echo "aetheros" > "$rootfs/etc/hostname"

    # Create hosts file
    cat > "$rootfs/etc/hosts" << EOF
127.0.0.1   localhost
127.0.1.1   aetheros

::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # Create system info
    cat > "$rootfs/etc/aetheros-release" << EOF
AETHEROS_VERSION=$AETHEROS_VERSION
AETHEROS_CODENAME=$AETHEROS_CODENAME
AETHEROS_BUILD_TYPE=$AETHEROS_BUILD_TYPE
AETHEROS_TARGET_ARCH=$AETHEROS_TARGET_ARCH
AETHEROS_BUILD_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF

    # Create init script (simple placeholder)
    cat > "$rootfs/init" << 'EOF'
#!/bin/sh
# Aether OS init script

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Create necessary device nodes if they don't exist
[ -e /dev/null ] || mknod /dev/null c 1 3
[ -e /dev/zero ] || mknod /dev/zero c 1 5
[ -e /dev/console ] || mknod /dev/console c 5 1

# Start compositor
if [ -x /system/bin/aether-compositor ]; then
    echo "Starting Aether OS compositor..."
    /system/bin/aether-compositor &
fi

# Keep init running
exec /bin/sh
EOF

    chmod +x "$rootfs/init"

    log_success "System configuration created"
    return 0
}

#
# Create build manifest
#
create_manifest() {
    log_info "Creating build manifest..."

    local manifest="$AETHEROS_OUT/images/$IMAGE_NAME.manifest"

    cat > "$manifest" << EOF
# Aether OS Build Manifest
# Build Information
VERSION=$AETHEROS_VERSION
CODENAME=$AETHEROS_CODENAME
BUILD_TYPE=$AETHEROS_BUILD_TYPE
TARGET_ARCH=$AETHEROS_TARGET_ARCH
BUILD_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
BUILD_HOST=$(hostname)
BUILD_USER=$(whoami)

# Image Information
IMAGE_NAME=$IMAGE_NAME.img
IMAGE_SIZE=$([ -f "$IMAGE_PATH" ] && du -h "$IMAGE_PATH" | cut -f1 || echo "N/A")

# Features
ENABLE_FLUTTER=$ENABLE_FLUTTER
ENABLE_WAYLAND=$ENABLE_WAYLAND
ENABLE_PIPEWIRE=$ENABLE_PIPEWIRE
ENABLE_SYSTEMD=$ENABLE_SYSTEMD
ENABLE_SELINUX=$ENABLE_SELINUX
ENABLE_VERIFIED_BOOT=$ENABLE_VERIFIED_BOOT

# Components
EOF

    # Add file counts
    if [ -d "$AETHEROS_OUT/rootfs" ]; then
        echo "ROOTFS_FILES=$(find $AETHEROS_OUT/rootfs -type f | wc -l)" >> "$manifest"
        echo "ROOTFS_SIZE=$(du -sh $AETHEROS_OUT/rootfs | cut -f1)" >> "$manifest"
    fi

    log_success "Build manifest created: $manifest"
    return 0
}

#
# Package root filesystem into image
#
create_image() {
    log_info "Creating system image..."

    local rootfs="$AETHEROS_OUT/rootfs"

    if [ ! -d "$rootfs" ]; then
        log_error "Root filesystem not found: $rootfs"
        return 1
    fi

    # Calculate required image size (rootfs size + 20% overhead)
    local rootfs_size=$(du -sm "$rootfs" | cut -f1)
    local image_size=$((rootfs_size + rootfs_size / 5 + 100))

    log_info "Root filesystem size: ${rootfs_size}MB"
    log_info "Creating ${image_size}MB image..."

    # Create empty image file
    dd if=/dev/zero of="$IMAGE_PATH" bs=1M count=$image_size >> "$BUILD_LOG" 2>&1

    # Create ext4 filesystem
    log_info "Creating ext4 filesystem..."
    mkfs.ext4 -F -L "AetherOS" "$IMAGE_PATH" >> "$BUILD_LOG" 2>&1

    # Mount image
    local mount_point="/tmp/aetheros-mount-$$"
    mkdir -p "$mount_point"

    log_info "Mounting image..."
    sudo mount -o loop "$IMAGE_PATH" "$mount_point" >> "$BUILD_LOG" 2>&1

    # Copy rootfs to image
    log_info "Copying rootfs to image..."
    sudo cp -a "$rootfs"/* "$mount_point/" >> "$BUILD_LOG" 2>&1

    # Unmount image
    log_info "Unmounting image..."
    sudo umount "$mount_point" >> "$BUILD_LOG" 2>&1
    rmdir "$mount_point"

    # Create symlink to latest image
    ln -sf "$IMAGE_NAME.img" "$AETHEROS_OUT/images/aetheros-system.img"

    # Create compressed version
    log_info "Compressing image..."
    gzip -c "$IMAGE_PATH" > "$IMAGE_PATH.gz"
    log_info "Compressed image: $IMAGE_PATH.gz"

    local final_size=$(du -h "$IMAGE_PATH" | cut -f1)
    local compressed_size=$(du -h "$IMAGE_PATH.gz" | cut -f1)

    log_success "System image created successfully"
    log_info "Image size: $final_size (compressed: $compressed_size)"
    log_info "Image location: $IMAGE_PATH"

    return 0
}

#
# Create update package
#
create_update_package() {
    log_info "Creating update package..."

    local package_dir="$AETHEROS_OUT/images/update-package"
    mkdir -p "$package_dir"

    # Copy essential files
    [ -f "$AETHEROS_OUT/rootfs/boot/Image" ] && cp "$AETHEROS_OUT/rootfs/boot/Image" "$package_dir/" || true
    [ -f "$IMAGE_PATH" ] && cp "$IMAGE_PATH" "$package_dir/system.img" || true

    # Create update script
    cat > "$package_dir/update.sh" << 'EOF'
#!/bin/bash
# Aether OS Update Script
echo "Installing Aether OS update..."
# TODO: Implement actual update logic
echo "Update complete!"
EOF
    chmod +x "$package_dir/update.sh"

    # Create tarball
    local package_name="$AETHEROS_OUT/images/$IMAGE_NAME-update.tar.gz"
    tar -czf "$package_name" -C "$(dirname $package_dir)" "$(basename $package_dir)" >> "$BUILD_LOG" 2>&1

    rm -rf "$package_dir"

    log_success "Update package created: $package_name"
    return 0
}

#
# Main build sequence
#
main() {
    local start_time=$(date +%s)

    log_info "Image Name: $IMAGE_NAME"
    log_info "Build Type: $AETHEROS_BUILD_TYPE"
    log_info "Target Architecture: $AETHEROS_TARGET_ARCH"
    echo ""

    # Create filesystem
    if ! create_rootfs_structure; then
        log_error "Failed to create rootfs structure"
        exit 1
    fi

    echo ""

    # Install components
    install_kernel
    echo ""

    if ! install_system; then
        log_error "Failed to install system components"
        exit 1
    fi

    echo ""

    if ! install_apps; then
        log_error "Failed to install applications"
        exit 1
    fi

    echo ""

    # Configure system
    if ! create_system_config; then
        log_error "Failed to create system configuration"
        exit 1
    fi

    echo ""

    # Create image
    if ! create_image; then
        log_error "Failed to create system image"
        exit 1
    fi

    echo ""

    # Create manifest
    create_manifest

    echo ""

    # Create update package
    create_update_package

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}  System Image Creation Complete!    ${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "Build time: ${duration}s"
    echo -e "Image: $IMAGE_PATH"
    echo -e "Log: $BUILD_LOG"
    echo ""
    echo -e "${BLUE}Flash image with:${NC}"
    echo -e "  aether-flash"
    echo -e "  or manually: sudo dd if=$IMAGE_PATH of=/dev/sdX bs=4M status=progress"
    echo ""

    return 0
}

# Run main
main "$@"
