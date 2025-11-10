cmake_minimum_required(VERSION 3.10)
project(libaether)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
set(SOURCES
    aether_native.cpp
)

set(HEADERS
    aether_native.h
)

# Create shared library
add_library(aether SHARED ${SOURCES})

# Set library properties
set_target_properties(aether PROPERTIES
    VERSION 1.0.0
    SOVERSION 1
    PUBLIC_HEADER "${HEADERS}"
)

# Installation
install(TARGETS aether
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/aetheros
)

# Create pkg-config file
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/libaether.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/libaether.pc
    @ONLY
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libaether.pc
    DESTINATION lib/pkgconfig
)
