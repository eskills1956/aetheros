/**
 * Aether OS Hardware Abstraction Layer (HAL) Interface
 *
 * Common interface for hardware module implementations
 */

#ifndef AETHER_HAL_H
#define AETHER_HAL_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// HAL API version
#define HAL_API_VERSION 1

// Module types
#define HAL_MODULE_AUDIO    "audio"
#define HAL_MODULE_DISPLAY  "display"
#define HAL_MODULE_CAMERA   "camera"
#define HAL_MODULE_SENSORS  "sensors"
#define HAL_MODULE_LIGHTS   "lights"
#define HAL_MODULE_VIBRATOR "vibrator"

// Return codes
#define HAL_SUCCESS            0
#define HAL_ERROR_NOT_FOUND   -1
#define HAL_ERROR_NO_MEMORY   -2
#define HAL_ERROR_INVALID_ARG -3
#define HAL_ERROR_NO_INIT     -4
#define HAL_ERROR_BAD_VALUE   -5

/**
 * HAL Module structure - common header for all HAL modules
 */
typedef struct hal_module {
    /** Version of the HAL API */
    uint32_t api_version;

    /** Module ID string */
    const char* id;

    /** Module name */
    const char* name;

    /** Module author */
    const char* author;

    /** Module version */
    uint32_t module_version;

    /** Reserved for future use */
    void* reserved[8];
} hal_module_t;

/**
 * HAL Device structure - common header for all HAL devices
 */
typedef struct hal_device {
    /** Common module reference */
    hal_module_t* module;

    /** Device version */
    uint32_t version;

    /** Device ID */
    const char* id;

    /** Device name */
    const char* name;

    /** Close the device */
    int (*close)(struct hal_device* device);

    /** Reserved for future use */
    void* reserved[8];
} hal_device_t;

/**
 * Open a HAL module
 *
 * @param id Module ID (e.g., HAL_MODULE_AUDIO)
 * @param module Output parameter for module structure
 * @return HAL_SUCCESS on success, error code otherwise
 */
int hal_open_module(const char* id, hal_module_t** module);

/**
 * Open a HAL device
 *
 * @param module HAL module
 * @param id Device ID
 * @param device Output parameter for device structure
 * @return HAL_SUCCESS on success, error code otherwise
 */
int hal_open_device(hal_module_t* module, const char* id, hal_device_t** device);

/**
 * Close a HAL device
 *
 * @param device Device to close
 * @return HAL_SUCCESS on success, error code otherwise
 */
int hal_close_device(hal_device_t* device);

#ifdef __cplusplus
}
#endif

#endif // AETHER_HAL_H
