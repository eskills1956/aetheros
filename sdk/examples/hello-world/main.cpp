#include <iostream>
#include <aetheros/aether.h>

int main() {
    std::cout << "=== Aether OS Hello World ===" << std::endl;
    std::cout << std::endl;

    // Display system information
    int32_t battery = aether_get_battery();
    int32_t signal = aether_get_signal();

    std::cout << "System Status:" << std::endl;
    std::cout << "  Battery: " << battery << "%" << std::endl;
    std::cout << "  Signal: " << signal << "/4 bars" << std::endl;

    // Send notification
    aether_notification_t notif = {
        .title = "Hello World",
        .message = "Application started successfully!",
        .icon = "info",
        .priority = 0
    };
    aether_send_notification(&notif);

    return 0;
}
