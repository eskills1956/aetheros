
cmake_minimum_required(VERSION 3.16)
project(aether-compositor)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(WAYLAND_SERVER REQUIRED wayland-server)
pkg_check_modules(WLROOTS REQUIRED wlroots)
pkg_check_modules(PIXMAN REQUIRED pixman-1)
pkg_check_modules(XKBCOMMON REQUIRED xkbcommon)

# Use main.cpp for now (or compositor.cpp if you saved the full version)
add_executable(aether-compositor main.cpp)

target_include_directories(aether-compositor PRIVATE
    ${WAYLAND_SERVER_INCLUDE_DIRS}
    ${WLROOTS_INCLUDE_DIRS}
    ${PIXMAN_INCLUDE_DIRS}
    ${XKBCOMMON_INCLUDE_DIRS}
)

target_link_libraries(aether-compositor
    ${WAYLAND_SERVER_LIBRARIES}
    ${WLROOTS_LIBRARIES}
    ${PIXMAN_LIBRARIES}
    ${XKBCOMMON_LIBRARIES}
)

install(TARGETS aether-compositor DESTINATION bin)