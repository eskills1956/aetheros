cmake_minimum_required(VERSION 3.10)
project(hello-world)

set(CMAKE_CXX_STANDARD 17)
set(AETHEROS_SDK $ENV{AETHEROS_SDK})

include_directories(${AETHEROS_SDK}/include)
link_directories(${AETHEROS_SDK}/libs)

add_executable(hello-world main.cpp)
target_link_libraries(hello-world aether)
