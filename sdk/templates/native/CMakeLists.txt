cmake_minimum_required(VERSION 3.10)
project({{APP_NAME}})

set(CMAKE_CXX_STANDARD 17)

# Find Aether OS SDK
set(AETHEROS_SDK $ENV{AETHEROS_SDK})
include_directories(${AETHEROS_SDK}/include)
link_directories(${AETHEROS_SDK}/libs)

add_executable({{APP_NAME}} main.cpp)
target_link_libraries({{APP_NAME}} aether)
