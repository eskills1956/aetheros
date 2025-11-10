cmake_minimum_required(VERSION 3.10)
project(aether-display-service)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
add_executable(aether-display-service
    display-service.cpp
)

# Installation
install(TARGETS aether-display-service
    RUNTIME DESTINATION bin
)
