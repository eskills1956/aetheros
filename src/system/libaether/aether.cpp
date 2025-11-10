/**
 * Aether OS Native Library
 *
 * Provides native bindings for Flutter and other applications to interact with system services
 */

#include "aether.h"
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

// Socket paths for system services
#define DISPLAY_SERVICE_SOCKET "/run/aether-display.sock"
#define POWER_SERVICE_SOCKET "/run/aether-power.sock"
#define AUDIO_SERVICE_SOCKET "/run/aether-audio.sock"

// Helper function to send command to service and get response
static std::string send_service_command(const char* socket_path, const char* command) {
    int sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock < 0) {
        std::cerr << "[libaether] Failed to create socket" << std::endl;
        return "ERROR";
    }

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);

    if (connect(sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        // Service not available, return simulated value
        close(sock);
        return "UNAVAILABLE";
    }

    // Send command
    ssize_t bytes_written = write(sock, command, strlen(command));
    if (bytes_written < 0) {
        close(sock);
        return "ERROR";
    }

    // Read response
    char buffer[256];
    int bytes_read = read(sock, buffer, sizeof(buffer) - 1);
    buffer[bytes_read > 0 ? bytes_read : 0] = '\0';

    close(sock);
    return std::string(buffer);
}

extern "C" {

// Battery functions
int32_t aether_get_battery() {
    std::string response = send_service_command(POWER_SERVICE_SOCKET, "GET_BATTERY");

    if (response == "UNAVAILABLE" || response == "ERROR") {
        // Return simulated value
        return 75;
    }

    return std::atoi(response.c_str());
}

int32_t aether_get_charging_status() {
    std::string response = send_service_command(POWER_SERVICE_SOCKET, "GET_CHARGING");

    if (response == "UNAVAILABLE" || response == "ERROR") {
        return 0;  // Not charging
    }

    return std::atoi(response.c_str());
}

// Signal strength (for mobile connectivity)
int32_t aether_get_signal() {
    // TODO: Connect to connectivity service when implemented
    // For now, return simulated value
    return 3;  // 3/4 bars
}

// Display functions
void aether_set_brightness(int32_t level) {
    char command[64];
    snprintf(command, sizeof(command), "SET_BRIGHTNESS:%d", level);
    send_service_command(DISPLAY_SERVICE_SOCKET, command);
}

int32_t aether_get_brightness() {
    std::string response = send_service_command(DISPLAY_SERVICE_SOCKET, "GET_BRIGHTNESS");

    if (response == "UNAVAILABLE" || response == "ERROR") {
        return 70;  // Default value
    }

    return std::atoi(response.c_str());
}

int aether_set_display_rotation(int32_t rotation) {
    char command[64];
    snprintf(command, sizeof(command), "SET_ROTATION:%d", rotation);
    std::string response = send_service_command(DISPLAY_SERVICE_SOCKET, command);
    return (response == "OK" || response == "UNAVAILABLE") ? 0 : -1;
}

int32_t aether_get_display_rotation() {
    std::string response = send_service_command(DISPLAY_SERVICE_SOCKET, "GET_ROTATION");

    if (response == "UNAVAILABLE" || response == "ERROR") {
        return 0;  // Default to 0 degrees
    }

    return std::atoi(response.c_str());
}

int aether_get_display_info(aether_display_info_t* info) {
    if (!info) return -1;

    // TODO: Get real display info from display service
    info->width = 1080;
    info->height = 2400;
    info->refresh_rate = 60;
    info->rotation = aether_get_display_rotation();

    return 0;
}

// Audio functions
void aether_set_volume(int32_t level) {
    // Set media volume (stream 0)
    char command[64];
    snprintf(command, sizeof(command), "SET_VOLUME:0:%d", level);
    send_service_command(AUDIO_SERVICE_SOCKET, command);
}

int32_t aether_get_volume() {
    // Get media volume (stream 0)
    std::string response = send_service_command(AUDIO_SERVICE_SOCKET, "GET_VOLUME:0");

    if (response == "UNAVAILABLE" || response == "ERROR") {
        return 70;  // Default value
    }

    return std::atoi(response.c_str());
}

void aether_set_mute(int32_t muted) {
    char command[64];
    snprintf(command, sizeof(command), "SET_MUTE:%d", muted);
    send_service_command(AUDIO_SERVICE_SOCKET, command);
}

int32_t aether_get_mute() {
    std::string response = send_service_command(AUDIO_SERVICE_SOCKET, "GET_MUTE");

    if (response == "UNAVAILABLE" || response == "ERROR") {
        return 0;  // Not muted
    }

    return std::atoi(response.c_str());
}

// Network status functions
int32_t aether_get_wifi_status() {
    // TODO: Connect to connectivity service when implemented
    return 1;  // WiFi on
}

int32_t aether_get_bluetooth_status() {
    // TODO: Connect to connectivity service when implemented
    return 0;  // Bluetooth off
}

// Power management functions
int aether_set_power_mode(aether_power_mode_t mode) {
    char command[64];
    snprintf(command, sizeof(command), "SET_POWER_MODE:%d", static_cast<int>(mode));
    std::string response = send_service_command(POWER_SERVICE_SOCKET, command);

    return (response == "OK") ? 0 : -1;
}

aether_power_mode_t aether_get_power_mode() {
    std::string response = send_service_command(POWER_SERVICE_SOCKET, "GET_POWER_MODE");

    if (response == "UNAVAILABLE" || response == "ERROR") {
        return AETHER_POWER_MODE_NORMAL;
    }

    return static_cast<aether_power_mode_t>(std::atoi(response.c_str()));
}

// Notification functions
int aether_send_notification(const aether_notification_t* notification) {
    if (!notification) return -1;

    // TODO: Connect to notification service when implemented
    std::cout << "[libaether] Notification: " << notification->title
              << " - " << notification->message << std::endl;

    return 0;
}

// System information functions
int aether_get_system_info(aether_system_info_t* info) {
    if (!info) return -1;

    info->version = "1.0.0";
    info->codename = "Aurora";
    info->build_type = "eng";
    info->arch = "arm64";

    return 0;
}

int aether_get_memory_info(aether_memory_info_t* info) {
    if (!info) return -1;

    // TODO: Read from /proc/meminfo
    info->total_ram = 4ULL * 1024 * 1024 * 1024;  // 4GB
    info->available_ram = 2ULL * 1024 * 1024 * 1024;  // 2GB
    info->total_storage = 64ULL * 1024 * 1024 * 1024;  // 64GB
    info->available_storage = 32ULL * 1024 * 1024 * 1024;  // 32GB

    return 0;
}

} // extern "C"
