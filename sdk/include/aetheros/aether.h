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
