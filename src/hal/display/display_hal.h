/**
 * Display HAL Interface
 */

#ifndef AETHER_DISPLAY_HAL_H
#define AETHER_DISPLAY_HAL_H

#include "../hal.h"

#ifdef __cplusplus
extern "C" {
#endif

// Display types
#define DISPLAY_TYPE_PRIMARY    0
#define DISPLAY_TYPE_EXTERNAL   1
#define DISPLAY_TYPE_VIRTUAL    2

// Pixel formats
#define PIXEL_FORMAT_RGBA_8888  1
#define PIXEL_FORMAT_RGBX_8888  2
#define PIXEL_FORMAT_RGB_888    3
#define PIXEL_FORMAT_RGB_565    4

/**
 * Display configuration
 */
typedef struct display_config {
    uint32_t width;
    uint32_t height;
    uint32_t format;
    uint32_t refresh_rate;
    uint32_t dpi;
} display_config_t;

/**
 * Framebuffer
 */
typedef struct framebuffer {
    uint32_t width;
    uint32_t height;
    uint32_t stride;
    uint32_t format;
    void* data;
} framebuffer_t;

/**
 * Display HAL device
 */
typedef struct display_hal_device {
    hal_device_t device;

    /** Get display configuration */
    int (*get_config)(struct display_hal_device* dev, display_config_t* config);

    /** Set display configuration */
    int (*set_config)(struct display_hal_device* dev, const display_config_t* config);

    /** Acquire framebuffer */
    int (*acquire_framebuffer)(struct display_hal_device* dev, framebuffer_t** fb);

    /** Release framebuffer */
    int (*release_framebuffer)(struct display_hal_device* dev, framebuffer_t* fb);

    /** Present framebuffer */
    int (*present)(struct display_hal_device* dev, framebuffer_t* fb);

    /** Set brightness (0-255) */
    int (*set_brightness)(struct display_hal_device* dev, uint8_t brightness);

    /** Get brightness */
    int (*get_brightness)(struct display_hal_device* dev, uint8_t* brightness);

    /** Set power mode (0=off, 1=on, 2=suspend) */
    int (*set_power_mode)(struct display_hal_device* dev, int mode);

    /** Enable/disable vsync */
    int (*set_vsync_enabled)(struct display_hal_device* dev, bool enabled);
} display_hal_device_t;

/**
 * Open display HAL device
 */
int display_hal_open(display_hal_device_t** device);

#ifdef __cplusplus
}
#endif

#endif // AETHER_DISPLAY_HAL_H
