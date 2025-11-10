/**
 * Unit tests for libaether native library
 */

#include <iostream>
#include <cassert>
#include <cstring>
#include "../../src/frameworks/flutter/libaether/aether_native.h"

// Simple test framework
#define TEST(name) \
    void test_##name(); \
    void run_test_##name() { \
        std::cout << "Running test: " << #name << "..."; \
        test_##name(); \
        std::cout << " PASSED" << std::endl; \
    } \
    void test_##name()

#define ASSERT_EQ(a, b) assert((a) == (b))
#define ASSERT_NE(a, b) assert((a) != (b))
#define ASSERT_TRUE(a) assert(a)
#define ASSERT_FALSE(a) assert(!(a))
#define ASSERT_GE(a, b) assert((a) >= (b))
#define ASSERT_LE(a, b) assert((a) <= (b))

// Test cases

TEST(initialization) {
    int32_t result = aether_init();
    ASSERT_EQ(result, 0);

    // Should be idempotent
    result = aether_init();
    ASSERT_EQ(result, 0);

    aether_shutdown();
}

TEST(battery_level) {
    aether_init();

    int32_t battery = aether_get_battery();
    ASSERT_GE(battery, 0);
    ASSERT_LE(battery, 100);

    aether_shutdown();
}

TEST(brightness_control) {
    aether_init();

    // Test setting brightness
    aether_set_brightness(50);
    ASSERT_EQ(aether_get_brightness(), 50);

    aether_set_brightness(100);
    ASSERT_EQ(aether_get_brightness(), 100);

    aether_set_brightness(0);
    ASSERT_EQ(aether_get_brightness(), 0);

    // Test clamping
    aether_set_brightness(150);
    ASSERT_EQ(aether_get_brightness(), 100);

    aether_set_brightness(-10);
    ASSERT_EQ(aether_get_brightness(), 0);

    aether_shutdown();
}

TEST(volume_control) {
    aether_init();

    // Test setting volume
    aether_set_volume(50);
    ASSERT_EQ(aether_get_volume(), 50);

    aether_set_volume(100);
    ASSERT_EQ(aether_get_volume(), 100);

    aether_set_volume(0);
    ASSERT_EQ(aether_get_volume(), 0);

    // Test mute
    aether_set_muted(1);
    ASSERT_EQ(aether_is_muted(), 1);

    aether_set_muted(0);
    ASSERT_EQ(aether_is_muted(), 0);

    aether_shutdown();
}

TEST(wifi_control) {
    aether_init();

    // Test WiFi enable/disable
    aether_set_wifi_enabled(1);
    ASSERT_EQ(aether_get_wifi_status(), 1);

    aether_set_wifi_enabled(0);
    ASSERT_EQ(aether_get_wifi_status(), 0);

    // Test signal strength
    aether_set_wifi_enabled(1);
    int32_t signal = aether_get_signal();
    ASSERT_GE(signal, 0);
    ASSERT_LE(signal, 4);

    aether_shutdown();
}

TEST(bluetooth_control) {
    aether_init();

    aether_set_bluetooth_enabled(1);
    ASSERT_EQ(aether_get_bluetooth_status(), 1);

    aether_set_bluetooth_enabled(0);
    ASSERT_EQ(aether_get_bluetooth_status(), 0);

    aether_shutdown();
}

TEST(airplane_mode) {
    aether_init();

    // Enable WiFi and Bluetooth first
    aether_set_wifi_enabled(1);
    aether_set_bluetooth_enabled(1);

    // Enable airplane mode should disable all radios
    aether_set_airplane_mode(1);
    ASSERT_EQ(aether_get_airplane_mode(), 1);
    ASSERT_EQ(aether_get_wifi_status(), 0);
    ASSERT_EQ(aether_get_bluetooth_status(), 0);

    // Disable airplane mode
    aether_set_airplane_mode(0);
    ASSERT_EQ(aether_get_airplane_mode(), 0);

    aether_shutdown();
}

TEST(system_info) {
    aether_init();

    // Test uptime (should be > 0 if system is running)
    uint64_t uptime = aether_get_uptime();
    ASSERT_GE(uptime, 0);

    // Test RAM info
    uint64_t total_ram = aether_get_total_ram();
    uint64_t available_ram = aether_get_available_ram();
    ASSERT_GE(total_ram, 0);
    ASSERT_GE(available_ram, 0);
    ASSERT_LE(available_ram, total_ram);

    // Test CPU usage
    int32_t cpu_usage = aether_get_cpu_usage();
    ASSERT_GE(cpu_usage, 0);
    ASSERT_LE(cpu_usage, 100);

    aether_shutdown();
}

TEST(low_power_mode) {
    aether_init();

    aether_set_low_power_mode(1);
    ASSERT_EQ(aether_is_low_power_mode(), 1);

    aether_set_low_power_mode(0);
    ASSERT_EQ(aether_is_low_power_mode(), 0);

    aether_shutdown();
}

// Test runner
int main() {
    std::cout << "==================================" << std::endl;
    std::cout << "  libaether Unit Tests" << std::endl;
    std::cout << "==================================" << std::endl;
    std::cout << std::endl;

    int tests_passed = 0;
    int tests_failed = 0;

    #define RUN_TEST(name) \
        try { \
            run_test_##name(); \
            tests_passed++; \
        } catch (...) { \
            std::cout << " FAILED" << std::endl; \
            tests_failed++; \
        }

    RUN_TEST(initialization);
    RUN_TEST(battery_level);
    RUN_TEST(brightness_control);
    RUN_TEST(volume_control);
    RUN_TEST(wifi_control);
    RUN_TEST(bluetooth_control);
    RUN_TEST(airplane_mode);
    RUN_TEST(system_info);
    RUN_TEST(low_power_mode);

    std::cout << std::endl;
    std::cout << "==================================" << std::endl;
    std::cout << "Results: " << tests_passed << " passed, " << tests_failed << " failed" << std::endl;
    std::cout << "==================================" << std::endl;

    return tests_failed > 0 ? 1 : 0;
}
