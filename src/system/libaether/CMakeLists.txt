cmake_minimum_required(VERSION 3.10)
project(libaether)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
add_library(aether SHARED
    aether.cpp
)

# Set library properties
set_target_properties(aether PROPERTIES
    VERSION 1.0.0
    SOVERSION 1
    PUBLIC_HEADER aether.h
)

# Installation
install(TARGETS aether
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/aetheros
)
