# Aether OS Hardware Abstraction Layer (HAL)

The Hardware Abstraction Layer (HAL) provides a standard interface between the Android OS and device-specific hardware implementations.

## Architecture

```
┌─────────────────────────────────────┐
│      System Services & Apps         │
├─────────────────────────────────────┤
│         HAL Interface (hal.h)       │
├─────────────────────────────────────┤
│      HAL Implementations            │
│  ┌────────┬────────┬──────────┐    │
│  │ Audio  │Display │ Sensors  │... │
│  └────────┴────────┴──────────┘    │
├─────────────────────────────────────┤
│      Hardware Drivers (Kernel)      │
└─────────────────────────────────────┘
```

## HAL Modules

### Audio HAL (`hal/audio/`)

Provides interface for audio input/output, volume control, and audio routing.

**Features:**
- Master volume and mute control
- Multiple sample rates and formats
- Input and output streams
- Buffer management

**Interface:**
- `audio_hal.h` - Audio HAL interface definitions
- `audio_hal_default.c` - Default reference implementation

**Usage:**
```c
#include "hal/audio/audio_hal.h"

audio_hal_device_t* audio_dev;
audio_hal_open(&audio_dev);

// Set volume
audio_dev->set_master_volume(audio_dev, 0.8f);

// Open output stream
audio_output_stream_t* stream;
audio_config_t config = {
    .sample_rate = AUDIO_SAMPLE_RATE_48000,
    .channel_count = AUDIO_CHANNEL_STEREO,
    .format = AUDIO_FORMAT_PCM_16_BIT,
};
audio_dev->open_output_stream(audio_dev, &config, &stream);

// Write audio data
stream->write(stream, buffer, size);
```

### Display HAL (`hal/display/`)

Provides interface for display management, framebuffer operations, and brightness control.

**Features:**
- Display configuration (resolution, DPI, refresh rate)
- Framebuffer acquisition and presentation
- Brightness control
- Power management
- VSync control

**Interface:**
- `display_hal.h` - Display HAL interface definitions

**Usage:**
```c
#include "hal/display/display_hal.h"

display_hal_device_t* display_dev;
display_hal_open(&display_dev);

// Set brightness
display_dev->set_brightness(display_dev, 200);

// Acquire and present framebuffer
framebuffer_t* fb;
display_dev->acquire_framebuffer(display_dev, &fb);
// ... draw to fb->data ...
display_dev->present(display_dev, fb);
display_dev->release_framebuffer(display_dev, fb);
```

### Camera HAL (`hal/camera/`)

*(To be implemented)*

Provides interface for camera capture, preview, and video recording.

### Sensors HAL (`hal/sensors/`)

*(To be implemented)*

Provides interface for various sensors:
- Accelerometer
- Gyroscope
- Magnetometer
- Light sensor
- Proximity sensor
- Barometer

### Lights HAL (`hal/lights/`)

*(To be implemented)*

Provides interface for device LEDs and notification lights.

### Vibrator HAL (`hal/vibrator/`)

*(To be implemented)*

Provides interface for haptic feedback control.

## Implementing a HAL Module

### 1. Define the Interface

Create a header file with your HAL interface:

```c
// hal/mydevice/mydevice_hal.h
#ifndef AETHER_MYDEVICE_HAL_H
#define AETHER_MYDEVICE_HAL_H

#include "../hal.h"

typedef struct mydevice_hal_device {
    hal_device_t device;

    // Your device-specific functions
    int (*do_something)(struct mydevice_hal_device* dev);
} mydevice_hal_device_t;

int mydevice_hal_open(mydevice_hal_device_t** device);

#endif
```

### 2. Implement the Module

Create an implementation file:

```c
// hal/mydevice/mydevice_hal_default.c
#include "mydevice_hal.h"
#include <stdlib.h>

static int mydevice_do_something(mydevice_hal_device_t* dev) {
    // Implementation
    return HAL_SUCCESS;
}

static int mydevice_close(hal_device_t* device) {
    free(device);
    return HAL_SUCCESS;
}

int mydevice_hal_open(mydevice_hal_device_t** device) {
    mydevice_hal_device_t* dev = calloc(1, sizeof(mydevice_hal_device_t));
    if (!dev) return HAL_ERROR_NO_MEMORY;

    dev->device.close = mydevice_close;
    dev->do_something = mydevice_do_something;

    *device = dev;
    return HAL_SUCCESS;
}
```

### 3. Vendor-Specific Overrides

Vendors can override default implementations:

```
device/<vendor>/<device>/hal/
    audio_hal_<vendor>.c
    display_hal_<vendor>.c
```

The build system will use vendor-specific implementations when available.

## Error Codes

All HAL functions return standard error codes:

- `HAL_SUCCESS (0)` - Operation successful
- `HAL_ERROR_NOT_FOUND (-1)` - Resource not found
- `HAL_ERROR_NO_MEMORY (-2)` - Out of memory
- `HAL_ERROR_INVALID_ARG (-3)` - Invalid argument
- `HAL_ERROR_NO_INIT (-4)` - Not initialized
- `HAL_ERROR_BAD_VALUE (-5)` - Bad value provided

## Best Practices

1. **Thread Safety**: HAL implementations should be thread-safe
2. **Resource Management**: Always release acquired resources
3. **Error Handling**: Return appropriate error codes
4. **Logging**: Use consistent logging for debugging
5. **Documentation**: Document vendor-specific behavior

## Building HAL Modules

HAL modules are built as part of the system build:

```bash
# Build all HAL modules
aether-build system

# Build specific HAL module
cd src/hal/audio
make
```

## Testing HAL Modules

Each HAL module should include tests:

```bash
# Run HAL tests
cd tests/hal
./test_audio_hal
./test_display_hal
```

## References

- Android HAL documentation
- Linux kernel driver interface
- ALSA audio API
- DRM/KMS display API
