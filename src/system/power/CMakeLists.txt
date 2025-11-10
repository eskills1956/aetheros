cmake_minimum_required(VERSION 3.10)
project(aether-power-service)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
set(SOURCES
    power_service.cpp
)

# Create executable
add_executable(aether-power-service ${SOURCES})

# Link libraries
target_link_libraries(aether-power-service
    pthread
)

# Install
install(TARGETS aether-power-service
    RUNTIME DESTINATION bin
)

# Install systemd service file
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/aether-power.service.in
    ${CMAKE_CURRENT_BINARY_DIR}/aether-power.service
    @ONLY
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/aether-power.service
    DESTINATION lib/systemd/system
)
