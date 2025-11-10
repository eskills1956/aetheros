cmake_minimum_required(VERSION 3.10)
project(aether-audio-service)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
set(SOURCES
    audio_service.cpp
)

# Create executable
add_executable(aether-audio-service ${SOURCES})

# Link libraries
target_link_libraries(aether-audio-service
    pthread
)

# In production, we would link against PipeWire:
# find_package(PkgConfig REQUIRED)
# pkg_check_modules(PIPEWIRE REQUIRED libpipewire-0.3)
# target_include_directories(aether-audio-service PRIVATE ${PIPEWIRE_INCLUDE_DIRS})
# target_link_libraries(aether-audio-service ${PIPEWIRE_LIBRARIES})

# Install
install(TARGETS aether-audio-service
    RUNTIME DESTINATION bin
)

# Install systemd service file
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/aether-audio.service.in
    ${CMAKE_CURRENT_BINARY_DIR}/aether-audio.service
    @ONLY
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/aether-audio.service
    DESTINATION lib/systemd/system
)
