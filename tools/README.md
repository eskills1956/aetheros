# Aether OS Development Tools

This directory contains various tools for building, debugging, and managing Aether OS.

## Build Tools

### aether-build

Unified build interface for Aether OS.

```bash
# Build entire system
aether-build all

# Build specific components
aether-build kernel
aether-build system
aether-build apps
aether-build sdk

# Build specific service
aether-build component display
aether-build component audio

# Build with options
aether-build all -j8          # Use 8 parallel jobs
aether-build kernel --verbose # Verbose output

# Clean builds
aether-build clean            # Clean build artifacts
aether-build distclean        # Clean everything

# Show build info
aether-build info
```

## Flashing Tools

### aether-flash

Flash system images to device.

```bash
# Flash all partitions
aether-flash --all

# Flash specific partitions
aether-flash --boot --system
aether-flash --boot
aether-flash --system

# List connected devices
aether-flash --list

# Factory reset
aether-flash --wipe

# Force flash (skip confirmation)
aether-flash --all --force
```

**Requirements:**
- fastboot installed
- Device in fastboot mode
- USB debugging enabled

## Debugging Tools

### aether-log

View system logs from device.

```bash
# View all logs
aether-log

# Follow logs in real-time
aether-log --follow

# View specific service logs
aether-log --service display
aether-log --service audio
aether-log --service power

# View kernel logs
aether-log --dmesg
aether-log --dmesg --follow

# Filter by log level
aether-log --level error
aether-log --level warn

# Show more lines
aether-log -n 100

# Clear logs
aether-log --clear
```

### aether-dev

Various development utilities.

```bash
# Open ADB shell
aether-dev shell

# Install/uninstall apps
aether-dev install app.apk
aether-dev uninstall com.example.app

# Screenshots and recording
aether-dev screenshot              # Save as screenshot.png
aether-dev screenshot my_screen.png
aether-dev screenrecord            # Record up to 3 minutes
aether-dev screenrecord video.mp4 60  # Record 60 seconds

# File transfer
aether-dev pull /sdcard/file.txt ./
aether-dev push ./file.txt /sdcard/

# Reboot
aether-dev reboot                  # Normal reboot
aether-dev reboot bootloader       # Reboot to fastboot
aether-dev reboot recovery         # Reboot to recovery

# Device information
aether-dev info                    # Show device details

# Performance testing
aether-dev benchmark               # Run benchmarks

# System tests
aether-dev test                    # Run test suite
```

## Legacy Scripts

### flashing/flash.sh

Basic flashing script (legacy). Use `aether-flash` instead.

### debugging/adb-shell.sh

Simple ADB shell opener (legacy). Use `aether-dev shell` instead.

## Installation

To use these tools system-wide, add them to your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/aetheros/tools"

# Or create symlinks
sudo ln -s /path/to/aetheros/tools/aether-* /usr/local/bin/
```

## Requirements

- **adb**: Android Debug Bridge
  ```bash
  # Ubuntu/Debian
  sudo apt-get install adb

  # Arch Linux
  sudo pacman -S android-tools

  # macOS
  brew install android-platform-tools
  ```

- **fastboot**: For flashing images
  ```bash
  # Usually comes with android-tools
  sudo apt-get install fastboot
  ```

- **Build tools**: For building the system
  ```bash
  sudo apt-get install build-essential cmake ninja-build
  ```

## Workflow Examples

### Full Development Cycle

```bash
# 1. Build the system
aether-build all -j$(nproc)

# 2. Flash to device
aether-flash --all

# 3. Monitor logs
aether-log --follow

# 4. Debug as needed
aether-dev shell
```

### Quick Service Development

```bash
# 1. Build specific service
aether-build component audio

# 2. Push to device
aether-dev push out/target/system/bin/aether-audio-service \
                 /system/bin/

# 3. Restart service on device
aether-dev shell
# Then: systemctl restart aether-audio

# 4. Check logs
aether-log --service audio --follow
```

### Testing Changes

```bash
# Build and test
aether-build all
aether-dev test

# If tests pass, flash and verify
aether-flash --all
aether-dev info
aether-dev benchmark
```

## Troubleshooting

### Device Not Detected

```bash
# Check USB connection
lsusb

# Restart ADB server
adb kill-server
adb start-server

# Check device
adb devices
aether-flash --list
```

### Flash Failures

```bash
# Verify images exist
ls -lh out/images/

# Try flashing partitions separately
aether-flash --boot
aether-flash --system

# Check fastboot connection
fastboot devices
```

### Build Errors

```bash
# Check environment
aether-build info

# Clean and rebuild
aether-build clean
aether-build all

# Verbose build
aether-build all --verbose
```

## Contributing

When adding new tools:

1. Make scripts executable: `chmod +x tool-name`
2. Add proper usage documentation (`--help`)
3. Include error checking and helpful messages
4. Update this README
5. Follow the naming convention: `aether-*`
