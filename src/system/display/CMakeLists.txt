cmake_minimum_required(VERSION 3.10)
project(aether-display-service)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Wayland
find_package(PkgConfig REQUIRED)
pkg_check_modules(WAYLAND REQUIRED wayland-server)

# Source files
set(SOURCES
    display_service.cpp
)

# Create executable
add_executable(aether-display-service ${SOURCES})

# Include directories
target_include_directories(aether-display-service PRIVATE
    ${WAYLAND_INCLUDE_DIRS}
)

# Link libraries
target_link_libraries(aether-display-service
    ${WAYLAND_LIBRARIES}
)

# Install
install(TARGETS aether-display-service
    RUNTIME DESTINATION bin
)

# Install systemd service file
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/aether-display.service.in
    ${CMAKE_CURRENT_BINARY_DIR}/aether-display.service
    @ONLY
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/aether-display.service
    DESTINATION lib/systemd/system
)
