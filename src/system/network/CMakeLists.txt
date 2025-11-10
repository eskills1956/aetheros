cmake_minimum_required(VERSION 3.10)
project(aether-network-service)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
set(SOURCES
    network_service.cpp
)

# Create executable
add_executable(aether-network-service ${SOURCES})

# Link libraries
target_link_libraries(aether-network-service
    pthread
)

# In production, we would link against NetworkManager and BlueZ:
# find_package(PkgConfig REQUIRED)
# pkg_check_modules(LIBNM REQUIRED libnm)
# pkg_check_modules(BLUEZ REQUIRED bluez)

# Install
install(TARGETS aether-network-service
    RUNTIME DESTINATION bin
)

# Install systemd service file
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/aether-network.service.in
    ${CMAKE_CURRENT_BINARY_DIR}/aether-network.service
    @ONLY
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/aether-network.service
    DESTINATION lib/systemd/system
)
