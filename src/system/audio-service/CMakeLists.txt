cmake_minimum_required(VERSION 3.10)
project(aether-audio-service)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
add_executable(aether-audio-service
    audio-service.cpp
)

# Installation
install(TARGETS aether-audio-service
    RUNTIME DESTINATION bin
)
