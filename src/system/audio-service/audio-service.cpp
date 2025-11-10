/**
 * Aether OS Audio Service
 *
 * Manages audio routing, volume control, and audio device configuration
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

// Audio service constants
#define AUDIO_SERVICE_SOCKET "/run/aether-audio.sock"

enum AudioDevice {
    SPEAKER = 0,
    HEADPHONES = 1,
    BLUETOOTH = 2,
    USB = 3
};

enum AudioStream {
    MEDIA = 0,
    RINGTONE = 1,
    NOTIFICATION = 2,
    ALARM = 3,
    VOICE_CALL = 4
};

class AudioService {
private:
    int server_socket;
    bool running;
    int volume_levels[5];  // Volume for each stream type
    AudioDevice active_device;
    bool muted;

public:
    AudioService() : server_socket(-1), running(false),
                     active_device(SPEAKER), muted(false) {
        // Initialize default volumes
        volume_levels[MEDIA] = 70;
        volume_levels[RINGTONE] = 80;
        volume_levels[NOTIFICATION] = 60;
        volume_levels[ALARM] = 90;
        volume_levels[VOICE_CALL] = 75;
    }

    ~AudioService() {
        stop();
    }

    bool init() {
        std::cout << "[AudioService] Initializing..." << std::endl;

        // Create Unix domain socket
        server_socket = socket(AF_UNIX, SOCK_STREAM, 0);
        if (server_socket < 0) {
            std::cerr << "[AudioService] Failed to create socket" << std::endl;
            return false;
        }

        // Remove old socket file if it exists
        unlink(AUDIO_SERVICE_SOCKET);

        // Bind socket
        struct sockaddr_un addr;
        memset(&addr, 0, sizeof(addr));
        addr.sun_family = AF_UNIX;
        strncpy(addr.sun_path, AUDIO_SERVICE_SOCKET, sizeof(addr.sun_path) - 1);

        if (bind(server_socket, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
            std::cerr << "[AudioService] Failed to bind socket" << std::endl;
            close(server_socket);
            return false;
        }

        // Listen for connections
        if (listen(server_socket, 5) < 0) {
            std::cerr << "[AudioService] Failed to listen on socket" << std::endl;
            close(server_socket);
            return false;
        }

        std::cout << "[AudioService] Initialized successfully" << std::endl;
        return true;
    }

    void run() {
        running = true;
        std::cout << "[AudioService] Service started" << std::endl;

        while (running) {
            fd_set read_fds;
            FD_ZERO(&read_fds);
            FD_SET(server_socket, &read_fds);

            struct timeval timeout;
            timeout.tv_sec = 1;
            timeout.tv_usec = 0;

            int activity = select(server_socket + 1, &read_fds, NULL, NULL, &timeout);

            if (activity < 0 && running) {
                std::cerr << "[AudioService] Select error" << std::endl;
                break;
            }

            if (activity > 0 && FD_ISSET(server_socket, &read_fds)) {
                handle_client();
            }
        }

        std::cout << "[AudioService] Service stopped" << std::endl;
    }

    void stop() {
        running = false;
        if (server_socket >= 0) {
            close(server_socket);
            unlink(AUDIO_SERVICE_SOCKET);
            server_socket = -1;
        }
    }

    void set_volume(AudioStream stream, int level) {
        if (level < 0) level = 0;
        if (level > 100) level = 100;

        volume_levels[stream] = level;

        const char* stream_name = get_stream_name(stream);
        std::cout << "[AudioService] " << stream_name << " volume set to " << level << "%" << std::endl;

        // TODO: Apply volume to PipeWire/ALSA
    }

    int get_volume(AudioStream stream) const {
        return volume_levels[stream];
    }

    void set_device(AudioDevice device) {
        active_device = device;

        const char* device_name = get_device_name(device);
        std::cout << "[AudioService] Active audio device: " << device_name << std::endl;

        // TODO: Route audio to selected device
    }

    AudioDevice get_device() const {
        return active_device;
    }

    void set_mute(bool mute) {
        muted = mute;
        std::cout << "[AudioService] Audio " << (mute ? "muted" : "unmuted") << std::endl;

        // TODO: Apply mute to audio system
    }

    bool is_muted() const {
        return muted;
    }

private:
    const char* get_stream_name(AudioStream stream) const {
        switch (stream) {
            case MEDIA: return "Media";
            case RINGTONE: return "Ringtone";
            case NOTIFICATION: return "Notification";
            case ALARM: return "Alarm";
            case VOICE_CALL: return "Voice Call";
            default: return "Unknown";
        }
    }

    const char* get_device_name(AudioDevice device) const {
        switch (device) {
            case SPEAKER: return "Speaker";
            case HEADPHONES: return "Headphones";
            case BLUETOOTH: return "Bluetooth";
            case USB: return "USB";
            default: return "Unknown";
        }
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

        if (cmd.find("GET_VOLUME:") == 0) {
            int stream = std::atoi(cmd.substr(11).c_str());
            if (stream >= 0 && stream <= 4) {
                return std::to_string(get_volume(static_cast<AudioStream>(stream)));
            }
            return "ERROR:Invalid stream";
        }
        else if (cmd.find("SET_VOLUME:") == 0) {
            // Format: SET_VOLUME:stream:level
            size_t first_colon = cmd.find(':', 11);
            if (first_colon != std::string::npos) {
                int stream = std::atoi(cmd.substr(11, first_colon - 11).c_str());
                int level = std::atoi(cmd.substr(first_colon + 1).c_str());
                if (stream >= 0 && stream <= 4) {
                    set_volume(static_cast<AudioStream>(stream), level);
                    return "OK";
                }
            }
            return "ERROR:Invalid command format";
        }
        else if (cmd.find("GET_DEVICE") == 0) {
            return std::to_string(static_cast<int>(get_device()));
        }
        else if (cmd.find("SET_DEVICE:") == 0) {
            int device = std::atoi(cmd.substr(11).c_str());
            if (device >= 0 && device <= 3) {
                set_device(static_cast<AudioDevice>(device));
                return "OK";
            }
            return "ERROR:Invalid device";
        }
        else if (cmd.find("GET_MUTE") == 0) {
            return is_muted() ? "1" : "0";
        }
        else if (cmd.find("SET_MUTE:") == 0) {
            int mute = std::atoi(cmd.substr(9).c_str());
            set_mute(mute != 0);
            return "OK";
        }
        else if (cmd.find("PLAY_SOUND:") == 0) {
            std::string sound_file = cmd.substr(11);
            std::cout << "[AudioService] Playing sound: " << sound_file << std::endl;
            // TODO: Play sound file
            return "OK";
        }

        return "ERROR:Unknown command";
    }
};

// Global service instance
AudioService* g_service = nullptr;

void signal_handler(int signum) {
    std::cout << "[AudioService] Received signal " << signum << std::endl;
    if (g_service) {
        g_service->stop();
    }
}

int main(int argc, char* argv[]) {
    std::cout << "==================================" << std::endl;
    std::cout << "  Aether OS Audio Service" << std::endl;
    std::cout << "==================================" << std::endl;

    // Setup signal handlers
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    // Create and initialize service
    AudioService service;
    g_service = &service;

    if (!service.init()) {
        std::cerr << "Failed to initialize audio service" << std::endl;
        return 1;
    }

    // Run service
    service.run();

    return 0;
}
