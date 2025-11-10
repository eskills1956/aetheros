# Aether OS Bootloader

This directory contains bootloader configurations and scripts for Aether OS.

## Components

### Boot Configuration

**aetheros.bootconfig** - Main boot configuration file
- Defines boot timeout and default entry
- Kernel command line parameters
- Boot entries (normal, recovery, fastboot)

### U-Boot Configuration

**u-boot/aetheros-arm64.conf** - U-Boot configuration for ARM64 devices
- Board and memory configuration
- Boot commands and environment variables
- Fastboot support
- USB gadget support
- Display and network configuration

### Boot Scripts

**scripts/boot-init.sh** - Early boot initialization script
- Mounts essential filesystems
- Initializes device nodes
- Loads kernel modules
- Sets up data partition
- Hands off to init system

## Boot Process

1. **Bootloader Stage** (U-Boot)
   - Hardware initialization
   - Load kernel and initramfs from boot partition
   - Pass control to kernel

2. **Kernel Stage**
   - Kernel initialization
   - Mount initial ramdisk
   - Execute init script

3. **Init Stage** (boot-init.sh)
   - Mount filesystems
   - Initialize devices
   - Set up system environment
   - Hand off to systemd/init

4. **System Stage**
   - Start system services
   - Mount data partition
   - Launch compositor and apps

## Supported Boot Modes

### Normal Boot
Default boot mode for regular system operation.

### Recovery Mode
Single-user mode for system recovery and maintenance.

### Fastboot Mode
Special mode for flashing system images over USB.

## Building Bootloader

For U-Boot:
```bash
# Configure U-Boot for your device
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- aetheros_defconfig

# Build U-Boot
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
```

## Customization

To customize boot parameters:

1. Edit `aetheros.bootconfig` for boot menu entries
2. Edit `u-boot/aetheros-arm64.conf` for U-Boot environment
3. Modify `scripts/boot-init.sh` for early boot behavior

## Device-Specific Configurations

Device-specific bootloader configurations should be placed in:
```
device/<vendor>/<device>/bootloader/
```

And referenced from the main bootloader configuration.
