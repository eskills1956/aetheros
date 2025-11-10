cmake_minimum_required(VERSION 3.10)
project(aether-power-service)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
add_executable(aether-power-service
    power-service.cpp
)

# Link pthread for threading support
target_link_libraries(aether-power-service pthread)

# Installation
install(TARGETS aether-power-service
    RUNTIME DESTINATION bin
)
