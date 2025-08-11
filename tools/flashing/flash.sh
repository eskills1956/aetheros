#!/bin/bash
# Aether OS Flashing Tool

set -e

IMAGES_DIR="$(dirname $0)/../../out/images"

echo "Aether OS Flash Tool"
echo "===================="

# Check for fastboot
if ! command -v fastboot &> /dev/null; then
    echo "Error: fastboot not found. Please install android-tools."
    exit 1
fi

# Check for images
if [ ! -f "$IMAGES_DIR/boot.img" ] || [ ! -f "$IMAGES_DIR/system.img" ]; then
    echo "Error: System images not found. Please build first."
    exit 1
fi

echo "Found device: $(fastboot devices)"
echo ""
echo "This will flash Aether OS to your device."
read -p "Continue? (y/N): " confirm

if [ "$confirm" != "y" ]; then
    echo "Aborted."
    exit 0
fi

echo "Flashing boot image..."
fastboot flash boot $IMAGES_DIR/boot.img

echo "Flashing system image..."
fastboot flash system $IMAGES_DIR/system.img

echo "Rebooting device..."
fastboot reboot

echo "Flash complete!"
