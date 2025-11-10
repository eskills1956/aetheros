/**
 * Display Service - Manages display and compositor integration
 * Part of Aether OS System Services
 */

#include <iostream>
#include <memory>
#include <csignal>
#include <cstring>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <wayland-server.h>

class DisplayService {
public:
    DisplayService() : running_(false), display_(nullptr) {}

    ~DisplayService() {
        shutdown();
    }

    bool initialize() {
        std::cout << "[DisplayService] Initializing..." << std::endl;

        // Create Wayland display
        display_ = wl_display_create();
        if (!display_) {
            std::cerr << "[DisplayService] Failed to create Wayland display" << std::endl;
            return false;
        }

        // Add socket for clients to connect
        const char* socket = wl_display_add_socket_auto(display_);
        if (!socket) {
            std::cerr << "[DisplayService] Failed to add Wayland socket" << std::endl;
            wl_display_destroy(display_);
            display_ = nullptr;
            return false;
        }

        // Set WAYLAND_DISPLAY environment variable
        setenv("WAYLAND_DISPLAY", socket, 1);

        std::cout << "[DisplayService] Wayland display socket: " << socket << std::endl;

        return true;
    }

    void run() {
        if (!display_) {
            std::cerr << "[DisplayService] Display not initialized" << std::endl;
            return;
        }

        std::cout << "[DisplayService] Starting display service..." << std::endl;
        running_ = true;

        // Main event loop
        while (running_) {
            wl_display_flush_clients(display_);
            wl_event_loop_dispatch(wl_display_get_event_loop(display_), 100);
        }

        std::cout << "[DisplayService] Display service stopped" << std::endl;
    }

    void shutdown() {
        std::cout << "[DisplayService] Shutting down..." << std::endl;
        running_ = false;

        if (display_) {
            wl_display_destroy(display_);
            display_ = nullptr;
        }
    }

    void stop() {
        running_ = false;
    }

private:
    bool running_;
    struct wl_display* display_;
};

// Global service instance for signal handling
static std::unique_ptr<DisplayService> g_service;

void signal_handler(int signal) {
    std::cout << "\n[DisplayService] Caught signal " << signal << std::endl;
    if (g_service) {
        g_service->stop();
    }
}

int main(int argc, char* argv[]) {
    std::cout << "Aether OS Display Service v1.0" << std::endl;
    std::cout << "===============================" << std::endl;

    // Setup signal handlers
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    // Create and initialize service
    g_service = std::make_unique<DisplayService>();

    if (!g_service->initialize()) {
        std::cerr << "[DisplayService] Failed to initialize" << std::endl;
        return 1;
    }

    // Run service
    g_service->run();

    // Cleanup
    g_service->shutdown();
    g_service.reset();

    std::cout << "[DisplayService] Exited cleanly" << std::endl;
    return 0;
}
