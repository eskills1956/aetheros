/**
 * Aether OS Display Service
 *
 * Manages display configuration, brightness, rotation, and other display-related settings
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

// Display service constants
#define DISPLAY_SERVICE_SOCKET "/run/aether-display.sock"
#define BRIGHTNESS_PATH "/sys/class/backlight/backlight/brightness"
#define MAX_BRIGHTNESS_PATH "/sys/class/backlight/backlight/max_brightness"

class DisplayService {
private:
    int server_socket;
    bool running;
    int current_brightness;
    int max_brightness;
    int current_rotation;  // 0, 90, 180, 270

public:
    DisplayService() : server_socket(-1), running(false),
                       current_brightness(50), max_brightness(100),
                       current_rotation(0) {}

    ~DisplayService() {
        stop();
    }

    bool init() {
        std::cout << "[DisplayService] Initializing..." << std::endl;

        // Read max brightness from sysfs (if available)
        std::ifstream max_brightness_file(MAX_BRIGHTNESS_PATH);
        if (max_brightness_file.is_open()) {
            max_brightness_file >> max_brightness;
            max_brightness_file.close();
            std::cout << "[DisplayService] Max brightness: " << max_brightness << std::endl;
        } else {
            std::cout << "[DisplayService] Warning: Cannot read max brightness, using default: "
                      << max_brightness << std::endl;
        }

        // Create Unix domain socket
        server_socket = socket(AF_UNIX, SOCK_STREAM, 0);
        if (server_socket < 0) {
            std::cerr << "[DisplayService] Failed to create socket" << std::endl;
            return false;
        }

        // Remove old socket file if it exists
        unlink(DISPLAY_SERVICE_SOCKET);

        // Bind socket
        struct sockaddr_un addr;
        memset(&addr, 0, sizeof(addr));
        addr.sun_family = AF_UNIX;
        strncpy(addr.sun_path, DISPLAY_SERVICE_SOCKET, sizeof(addr.sun_path) - 1);

        if (bind(server_socket, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
            std::cerr << "[DisplayService] Failed to bind socket" << std::endl;
            close(server_socket);
            return false;
        }

        // Listen for connections
        if (listen(server_socket, 5) < 0) {
            std::cerr << "[DisplayService] Failed to listen on socket" << std::endl;
            close(server_socket);
            return false;
        }

        std::cout << "[DisplayService] Initialized successfully" << std::endl;
        return true;
    }

    void run() {
        running = true;
        std::cout << "[DisplayService] Service started" << std::endl;

        while (running) {
            fd_set read_fds;
            FD_ZERO(&read_fds);
            FD_SET(server_socket, &read_fds);

            struct timeval timeout;
            timeout.tv_sec = 1;
            timeout.tv_usec = 0;

            int activity = select(server_socket + 1, &read_fds, NULL, NULL, &timeout);

            if (activity < 0 && running) {
                std::cerr << "[DisplayService] Select error" << std::endl;
                break;
            }

            if (activity > 0 && FD_ISSET(server_socket, &read_fds)) {
                handle_client();
            }
        }

        std::cout << "[DisplayService] Service stopped" << std::endl;
    }

    void stop() {
        running = false;
        if (server_socket >= 0) {
            close(server_socket);
            unlink(DISPLAY_SERVICE_SOCKET);
            server_socket = -1;
        }
    }

    void set_brightness(int level) {
        if (level < 0) level = 0;
        if (level > 100) level = 100;

        current_brightness = level;

        // Write to sysfs
        std::ofstream brightness_file(BRIGHTNESS_PATH);
        if (brightness_file.is_open()) {
            int actual_brightness = (level * max_brightness) / 100;
            brightness_file << actual_brightness;
            brightness_file.close();
            std::cout << "[DisplayService] Brightness set to " << level << "%" << std::endl;
        } else {
            std::cout << "[DisplayService] Warning: Cannot write brightness (sysfs not available)" << std::endl;
        }
    }

    int get_brightness() const {
        return current_brightness;
    }

    void set_rotation(int rotation) {
        // Normalize rotation to 0, 90, 180, 270
        rotation = ((rotation % 360) / 90) * 90;
        current_rotation = rotation;
        std::cout << "[DisplayService] Rotation set to " << rotation << " degrees" << std::endl;

        // TODO: Signal compositor to rotate display
    }

    int get_rotation() const {
        return current_rotation;
    }

private:
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

        if (cmd.find("GET_BRIGHTNESS") == 0) {
            return std::to_string(get_brightness());
        }
        else if (cmd.find("SET_BRIGHTNESS:") == 0) {
            int level = std::atoi(cmd.substr(15).c_str());
            set_brightness(level);
            return "OK";
        }
        else if (cmd.find("GET_ROTATION") == 0) {
            return std::to_string(get_rotation());
        }
        else if (cmd.find("SET_ROTATION:") == 0) {
            int rotation = std::atoi(cmd.substr(13).c_str());
            set_rotation(rotation);
            return "OK";
        }
        else if (cmd.find("GET_INFO") == 0) {
            return "DISPLAY:1920x1080:60Hz";
        }

        return "ERROR:Unknown command";
    }
};

// Global service instance
DisplayService* g_service = nullptr;

void signal_handler(int signum) {
    std::cout << "[DisplayService] Received signal " << signum << std::endl;
    if (g_service) {
        g_service->stop();
    }
}

int main(int argc, char* argv[]) {
    std::cout << "==================================" << std::endl;
    std::cout << "  Aether OS Display Service" << std::endl;
    std::cout << "==================================" << std::endl;

    // Setup signal handlers
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    // Create and initialize service
    DisplayService service;
    g_service = &service;

    if (!service.init()) {
        std::cerr << "Failed to initialize display service" << std::endl;
        return 1;
    }

    // Set default brightness
    service.set_brightness(70);

    // Run service
    service.run();

    return 0;
}
