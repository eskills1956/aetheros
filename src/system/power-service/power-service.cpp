/**
 * Aether OS Power Service
 *
 * Manages power states, battery monitoring, and power-saving features
 */

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <unistd.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <cstring>
#include <thread>
#include <chrono>

// Power service constants
#define POWER_SERVICE_SOCKET "/run/aether-power.sock"
#define BATTERY_CAPACITY_PATH "/sys/class/power_supply/battery/capacity"
#define BATTERY_STATUS_PATH "/sys/class/power_supply/battery/status"

enum PowerMode {
    NORMAL = 0,
    POWER_SAVE = 1,
    ULTRA_POWER_SAVE = 2
};

class PowerService {
private:
    int server_socket;
    bool running;
    int battery_level;
    bool is_charging;
    PowerMode power_mode;
    std::thread monitor_thread;

public:
    PowerService() : server_socket(-1), running(false),
                     battery_level(100), is_charging(false),
                     power_mode(NORMAL) {}

    ~PowerService() {
        stop();
    }

    bool init() {
        std::cout << "[PowerService] Initializing..." << std::endl;

        // Create Unix domain socket
        server_socket = socket(AF_UNIX, SOCK_STREAM, 0);
        if (server_socket < 0) {
            std::cerr << "[PowerService] Failed to create socket" << std::endl;
            return false;
        }

        // Remove old socket file if it exists
        unlink(POWER_SERVICE_SOCKET);

        // Bind socket
        struct sockaddr_un addr;
        memset(&addr, 0, sizeof(addr));
        addr.sun_family = AF_UNIX;
        strncpy(addr.sun_path, POWER_SERVICE_SOCKET, sizeof(addr.sun_path) - 1);

        if (bind(server_socket, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
            std::cerr << "[PowerService] Failed to bind socket" << std::endl;
            close(server_socket);
            return false;
        }

        // Listen for connections
        if (listen(server_socket, 5) < 0) {
            std::cerr << "[PowerService] Failed to listen on socket" << std::endl;
            close(server_socket);
            return false;
        }

        std::cout << "[PowerService] Initialized successfully" << std::endl;
        return true;
    }

    void run() {
        running = true;
        std::cout << "[PowerService] Service started" << std::endl;

        // Start battery monitoring thread
        monitor_thread = std::thread(&PowerService::monitor_battery, this);

        while (running) {
            fd_set read_fds;
            FD_ZERO(&read_fds);
            FD_SET(server_socket, &read_fds);

            struct timeval timeout;
            timeout.tv_sec = 1;
            timeout.tv_usec = 0;

            int activity = select(server_socket + 1, &read_fds, NULL, NULL, &timeout);

            if (activity < 0 && running) {
                std::cerr << "[PowerService] Select error" << std::endl;
                break;
            }

            if (activity > 0 && FD_ISSET(server_socket, &read_fds)) {
                handle_client();
            }
        }

        // Wait for monitor thread to finish
        if (monitor_thread.joinable()) {
            monitor_thread.join();
        }

        std::cout << "[PowerService] Service stopped" << std::endl;
    }

    void stop() {
        running = false;
        if (server_socket >= 0) {
            close(server_socket);
            unlink(POWER_SERVICE_SOCKET);
            server_socket = -1;
        }
    }

    int get_battery_level() {
        // Try to read from sysfs
        std::ifstream capacity_file(BATTERY_CAPACITY_PATH);
        if (capacity_file.is_open()) {
            capacity_file >> battery_level;
            capacity_file.close();
        }
        // If file doesn't exist, use simulated value
        return battery_level;
    }

    bool get_charging_status() {
        std::ifstream status_file(BATTERY_STATUS_PATH);
        if (status_file.is_open()) {
            std::string status;
            status_file >> status;
            status_file.close();
            is_charging = (status == "Charging" || status == "Full");
        }
        return is_charging;
    }

    void set_power_mode(PowerMode mode) {
        power_mode = mode;
        std::cout << "[PowerService] Power mode set to ";
        switch (mode) {
            case NORMAL:
                std::cout << "NORMAL" << std::endl;
                break;
            case POWER_SAVE:
                std::cout << "POWER_SAVE" << std::endl;
                apply_power_save_settings();
                break;
            case ULTRA_POWER_SAVE:
                std::cout << "ULTRA_POWER_SAVE" << std::endl;
                apply_ultra_power_save_settings();
                break;
        }
    }

    PowerMode get_power_mode() const {
        return power_mode;
    }

private:
    void monitor_battery() {
        std::cout << "[PowerService] Battery monitoring started" << std::endl;

        while (running) {
            int level = get_battery_level();
            bool charging = get_charging_status();

            // Check for low battery
            if (!charging && level <= 15) {
                std::cout << "[PowerService] WARNING: Battery low (" << level << "%)" << std::endl;
                if (level <= 5) {
                    std::cout << "[PowerService] CRITICAL: Battery critical (" << level << "%)" << std::endl;
                    // TODO: Trigger low battery notification
                }
            }

            // Auto-enable power save mode when battery is low
            if (!charging && level <= 20 && power_mode == NORMAL) {
                std::cout << "[PowerService] Auto-enabling power save mode" << std::endl;
                set_power_mode(POWER_SAVE);
            }

            // Sleep for 10 seconds before next check
            std::this_thread::sleep_for(std::chrono::seconds(10));
        }

        std::cout << "[PowerService] Battery monitoring stopped" << std::endl;
    }

    void apply_power_save_settings() {
        // Reduce display brightness
        // Limit CPU frequency
        // Disable background sync
        std::cout << "[PowerService] Applying power save settings..." << std::endl;
        // TODO: Implement actual power saving measures
    }

    void apply_ultra_power_save_settings() {
        // Aggressive power savings
        // Minimum display brightness
        // Disable non-essential services
        std::cout << "[PowerService] Applying ultra power save settings..." << std::endl;
        // TODO: Implement ultra power saving measures
    }

    void handle_client() {
        int client_socket = accept(server_socket, NULL, NULL);
        if (client_socket < 0) {
            return;
        }

        char buffer[256];
        int bytes_read = read(client_socket, buffer, sizeof(buffer) - 1);

        if (bytes_read > 0) {
            buffer[bytes_read] = '\0';
            std::string response = process_command(buffer);
            write(client_socket, response.c_str(), response.length());
        }

        close(client_socket);
    }

    std::string process_command(const char* command) {
        std::string cmd(command);

        if (cmd.find("GET_BATTERY") == 0) {
            return std::to_string(get_battery_level());
        }
        else if (cmd.find("GET_CHARGING") == 0) {
            return get_charging_status() ? "1" : "0";
        }
        else if (cmd.find("GET_POWER_MODE") == 0) {
            return std::to_string(static_cast<int>(get_power_mode()));
        }
        else if (cmd.find("SET_POWER_MODE:") == 0) {
            int mode = std::atoi(cmd.substr(15).c_str());
            if (mode >= 0 && mode <= 2) {
                set_power_mode(static_cast<PowerMode>(mode));
                return "OK";
            }
            return "ERROR:Invalid power mode";
        }
        else if (cmd.find("SUSPEND") == 0) {
            std::cout << "[PowerService] Suspend requested" << std::endl;
            // TODO: Implement suspend
            return "OK";
        }
        else if (cmd.find("SHUTDOWN") == 0) {
            std::cout << "[PowerService] Shutdown requested" << std::endl;
            // TODO: Implement shutdown
            return "OK";
        }
        else if (cmd.find("REBOOT") == 0) {
            std::cout << "[PowerService] Reboot requested" << std::endl;
            // TODO: Implement reboot
            return "OK";
        }

        return "ERROR:Unknown command";
    }
};

// Global service instance
PowerService* g_service = nullptr;

void signal_handler(int signum) {
    std::cout << "[PowerService] Received signal " << signum << std::endl;
    if (g_service) {
        g_service->stop();
    }
}

int main(int argc, char* argv[]) {
    std::cout << "==================================" << std::endl;
    std::cout << "  Aether OS Power Service" << std::endl;
    std::cout << "==================================" << std::endl;

    // Setup signal handlers
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    // Create and initialize service
    PowerService service;
    g_service = &service;

    if (!service.init()) {
        std::cerr << "Failed to initialize power service" << std::endl;
        return 1;
    }

    // Run service
    service.run();

    return 0;
}
