/**
 * Native Library for Flutter FFI Integration
 * Provides system-level access to Aether OS services
 */

#ifndef AETHER_NATIVE_H
#define AETHER_NATIVE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Version information
#define AETHER_API_VERSION 1

/**
 * Initialize the Aether native library
 * Returns 0 on success, negative on error
 */
int32_t aether_init(void);

/**
 * Cleanup and shutdown the library
 */
void aether_shutdown(void);

// ===== Battery and Power Management =====

/**
 * Get battery level (0-100)
 * Returns -1 if battery info not available
 */
int32_t aether_get_battery(void);

/**
 * Check if device is charging
 * Returns 1 if charging, 0 if not, -1 on error
 */
int32_t aether_is_charging(void);

/**
 * Get screen brightness (0-100)
 */
int32_t aether_get_brightness(void);

/**
 * Set screen brightness (0-100)
 */
void aether_set_brightness(int32_t level);

/**
 * Enable/disable low power mode
 */
void aether_set_low_power_mode(int32_t enabled);

/**
 * Check if low power mode is enabled
 */
int32_t aether_is_low_power_mode(void);

// ===== Audio =====

/**
 * Get system volume (0-100)
 */
int32_t aether_get_volume(void);

/**
 * Set system volume (0-100)
 */
void aether_set_volume(int32_t level);

/**
 * Check if audio is muted
 */
int32_t aether_is_muted(void);

/**
 * Mute/unmute audio
 */
void aether_set_muted(int32_t muted);

// ===== Network =====

/**
 * Get WiFi status (0=off, 1=on)
 */
int32_t aether_get_wifi_status(void);

/**
 * Enable/disable WiFi
 */
void aether_set_wifi_enabled(int32_t enabled);

/**
 * Get WiFi signal strength (0-4 bars)
 * Returns -1 if WiFi is off or not connected
 */
int32_t aether_get_signal(void);

/**
 * Get connected WiFi SSID
 * Returns pointer to SSID string, or NULL if not connected
 * Note: Caller must not free the returned string
 */
const char* aether_get_wifi_ssid(void);

/**
 * Get Bluetooth status (0=off, 1=on)
 */
int32_t aether_get_bluetooth_status(void);

/**
 * Enable/disable Bluetooth
 */
void aether_set_bluetooth_enabled(int32_t enabled);

/**
 * Get mobile data status (0=off, 1=on)
 */
int32_t aether_get_mobile_data_status(void);

/**
 * Enable/disable mobile data
 */
void aether_set_mobile_data_enabled(int32_t enabled);

/**
 * Get airplane mode status (0=off, 1=on)
 */
int32_t aether_get_airplane_mode(void);

/**
 * Enable/disable airplane mode
 */
void aether_set_airplane_mode(int32_t enabled);

// ===== System Information =====

/**
 * Get system uptime in seconds
 */
uint64_t aether_get_uptime(void);

/**
 * Get available RAM in MB
 */
uint64_t aether_get_available_ram(void);

/**
 * Get total RAM in MB
 */
uint64_t aether_get_total_ram(void);

/**
 * Get CPU usage percentage (0-100)
 */
int32_t aether_get_cpu_usage(void);

#ifdef __cplusplus
}
#endif

#endif // AETHER_NATIVE_H
