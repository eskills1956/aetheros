/**
 * Aether OS System API
 */

#ifndef AETHEROS_SYSTEM_H
#define AETHEROS_SYSTEM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

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

#ifdef __cplusplus
}
#endif

#endif // AETHEROS_SYSTEM_H
