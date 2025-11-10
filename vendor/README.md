# Vendor-Specific Code

This directory contains vendor-specific implementations and drivers for Aether OS.

## Directory Structure

```
vendor/
├── generic/        # Generic reference implementations
├── qcom/          # Qualcomm Snapdragon devices
├── mediatek/      # MediaTek devices
└── README.md
```

## Purpose

Vendor directories contain:

1. **Hardware-specific drivers**
2. **Proprietary firmware blobs**
3. **Device-specific HAL implementations**
4. **Optimized libraries**
5. **Calibration data**

## Adding Vendor Support

### 1. Create Vendor Directory

```bash
mkdir -p vendor/<vendor_name>/<device_name>
cd vendor/<vendor_name>/<device_name>
```

### 2. Directory Structure

```
vendor/<vendor>/<device>/
├── device.mk                # Device makefile
├── BoardConfig.mk           # Board configuration
├── proprietary/             # Proprietary binaries
│   ├── firmware/           # Firmware blobs
│   ├── lib/                # Proprietary libraries
│   └── bin/                # Proprietary executables
├── hal/                     # HAL implementations
│   ├── audio/
│   ├── display/
│   └── camera/
└── kernel/                  # Kernel configuration
    └── defconfig
```

### 3. Device Makefile

Create `device.mk`:

```makefile
# Device identification
PRODUCT_NAME := aetheros_<device>
PRODUCT_DEVICE := <device>
PRODUCT_MANUFACTURER := <vendor>
PRODUCT_MODEL := <model>

# Inherit from generic configuration
$(call inherit-product, device/generic/arm64/device.mk)

# Vendor-specific HAL modules
PRODUCT_PACKAGES += \
    audio.primary.<device> \
    display.primary.<device> \
    camera.<device>

# Proprietary files
$(call inherit-product-if-exists, vendor/<vendor>/<device>/proprietary.mk)

# Kernel configuration
BOARD_KERNEL_CMDLINE := androidboot.hardware=<device>
```

### 4. Board Configuration

Create `BoardConfig.mk`:

```makefile
# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := <device>
TARGET_NO_BOOTLOADER := false

# Kernel
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
TARGET_PREBUILT_KERNEL := vendor/<vendor>/<device>/kernel/Image

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3221225472
BOARD_USERDATAIMAGE_PARTITION_SIZE := 10737418240

# Display
TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_HEIGHT := 2340
TARGET_SCREEN_DENSITY := 420
```

### 5. Proprietary Files

List proprietary files in `proprietary-files.txt`:

```
# Audio
vendor/lib64/libaudiohal.so
vendor/firmware/audio/audio.bin

# Display
vendor/lib64/libgpu.so
vendor/firmware/display/panel.bin

# Camera
vendor/lib64/libcamera.so
vendor/firmware/camera/isp.bin
```

## Vendor-Specific HAL

Override default HAL implementations:

```c
// vendor/qcom/sdm845/hal/audio/audio_hal_qcom.c
#include "hal/audio/audio_hal.h"

// Qualcomm-specific implementation
int audio_hal_open_qcom(audio_hal_device_t** device) {
    // Vendor-specific initialization
    // ...
    return HAL_SUCCESS;
}
```

## Building with Vendor Code

```bash
# Set vendor
export AETHEROS_VENDOR=qcom
export AETHEROS_DEVICE=sdm845

# Build
aether-build all
```

## Extracting Proprietary Files

Use the extraction tool:

```bash
# Connect device with stock firmware
adb root
adb remount

# Extract proprietary files
tools/extract-vendor.sh <vendor> <device>

# This creates:
# vendor/<vendor>/<device>/proprietary/
```

## License Considerations

- **Proprietary Blobs**: Retain original license
- **Open Source**: Follow Apache 2.0 License
- **Document**: Clearly mark proprietary vs. open source

## Example Vendors

### Generic (Reference)

Generic implementations for testing and development:

```
vendor/generic/arm64/
```

### Qualcomm

Support for Snapdragon-powered devices:

```
vendor/qcom/
├── sdm845/     # Snapdragon 845
├── sm8150/     # Snapdragon 855
└── sm8250/     # Snapdragon 865
```

### MediaTek

Support for MediaTek-powered devices:

```
vendor/mediatek/
├── mt6797/     # Helio X30
└── mt6889/     # Dimensity 1000
```

## Vendor Security

1. **Verify Sources**: Only use binaries from trusted sources
2. **Check Signatures**: Verify cryptographic signatures
3. **Scan for Malware**: Run antivirus scans
4. **Review Permissions**: Check required permissions
5. **Update Regularly**: Keep firmware up to date

## Contributing

When adding vendor support:

1. Test thoroughly on target hardware
2. Document device-specific quirks
3. Minimize proprietary dependencies
4. Provide fallback implementations
5. Update build system integration

## Support

For vendor-specific issues:

1. Check device documentation
2. Contact vendor support
3. Join device-specific forums
4. File issues on GitHub with [VENDOR] tag
