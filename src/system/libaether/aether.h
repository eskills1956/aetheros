/**
 * Aether OS SDK - Native Library Header
 *
 * This is the implementation header. The public SDK header is in sdk/include/aetheros/aether.h
 */

#ifndef AETHEROS_LIBAETHER_H
#define AETHEROS_LIBAETHER_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Display functions
typedef struct {
    int32_t width;
    int32_t height;
    int32_t refresh_rate;
    int32_t rotation;
} aether_display_info_t;

int aether_get_display_info(aether_display_info_t *info);
int aether_set_display_rotation(int32_t rotation);
int32_t aether_get_display_rotation(void);

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

// System information
typedef struct {
    const char *version;
    const char *codename;
    const char *build_type;
    const char *arch;
} aether_system_info_t;

int aether_get_system_info(aether_system_info_t *info);

// Memory information
typedef struct {
    uint64_t total_ram;
    uint64_t available_ram;
    uint64_t total_storage;
    uint64_t available_storage;
} aether_memory_info_t;

int aether_get_memory_info(aether_memory_info_t *info);

// Basic system functions (implemented for Flutter FFI compatibility)
int32_t aether_get_battery(void);
int32_t aether_get_charging_status(void);
int32_t aether_get_signal(void);
void aether_set_brightness(int32_t level);
int32_t aether_get_brightness(void);
void aether_set_volume(int32_t level);
int32_t aether_get_volume(void);
void aether_set_mute(int32_t muted);
int32_t aether_get_mute(void);
int32_t aether_get_wifi_status(void);
int32_t aether_get_bluetooth_status(void);

#ifdef __cplusplus
}
#endif

#endif // AETHEROS_LIBAETHER_H
