#include <iostream>
#include <aetheros/aether.h>

int main() {
    std::cout << "Hello from Aether OS!" << std::endl;

    // Example: Get battery level
    int32_t battery = aether_get_battery();
    std::cout << "Battery level: " << battery << "%" << std::endl;

    return 0;
}
