cmake_minimum_required(VERSION 3.10)
project(aetheros_unit_tests)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find libaether
include_directories(${CMAKE_SOURCE_DIR}/../../src/frameworks/flutter/libaether)

# Test executables
add_executable(test_libaether test_libaether.cpp
    ${CMAKE_SOURCE_DIR}/../../src/frameworks/flutter/libaether/aether_native.cpp
)

# Enable testing
enable_testing()

# Add tests
add_test(NAME libaether_tests COMMAND test_libaether)
