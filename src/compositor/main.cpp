// Aether OS Wayland Compositor
// Minimal implementation using wlroots

#include <wayland-server-core.h>
#include <wlr/backend.h>
#include <wlr/render/allocator.h>
#include <wlr/render/wlr_renderer.h>
#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_data_device.h>
#include <wlr/types/wlr_output.h>
#include <wlr/types/wlr_output_layout.h>
#include <wlr/types/wlr_scene.h>
#include <wlr/types/wlr_seat.h>
#include <wlr/types/wlr_xdg_shell.h>
#include <wlr/util/log.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

struct aether_server {
    struct wl_display *wl_display;
    struct wlr_backend *backend;
    struct wlr_renderer *renderer;
    struct wlr_allocator *allocator;
    struct wlr_scene *scene;
    struct wlr_scene_output_layout *scene_layout;
    struct wlr_output_layout *output_layout;
    struct wlr_compositor *compositor;
    struct wlr_xdg_shell *xdg_shell;
    struct wlr_seat *seat;
    
    struct wl_listener new_output;
    struct wl_listener new_xdg_surface;
};

static void handle_new_output(struct wl_listener *listener, void *data) {
    struct aether_server *server = wl_container_of(listener, server, new_output);
    struct wlr_output *output = (struct wlr_output *)data;
    
    // Initialize the output
    wlr_output_init_render(output, server->allocator, server->renderer);
    
    // Pick the preferred mode
    struct wlr_output_state state;
    wlr_output_state_init(&state);
    wlr_output_state_set_enabled(&state, true);
    
    struct wlr_output_mode *mode = wlr_output_preferred_mode(output);
    if (mode != NULL) {
        wlr_output_state_set_mode(&state, mode);
    }
    
    wlr_output_commit_state(output, &state);
    wlr_output_state_finish(&state);
    
    // Add output to layout
    wlr_output_layout_add_auto(server->output_layout, output);
    
    // Create a scene output
    struct wlr_scene_output *scene_output = 
        wlr_scene_output_create(server->scene, output);
    wlr_scene_output_layout_add_output(server->scene_layout, 
        server->output_layout, output);
}

static void handle_new_xdg_surface(struct wl_listener *listener, void *data) {
    struct aether_server *server = wl_container_of(listener, server, new_xdg_surface);
    struct wlr_xdg_surface *xdg_surface = (struct wlr_xdg_surface *)data;
    
    if (xdg_surface->role == WLR_XDG_SURFACE_ROLE_POPUP) {
        return;
    }
    
    // Create scene tree for this surface
    wlr_scene_xdg_surface_create(&server->scene->tree, xdg_surface);
}

static void handle_signal(int sig) {
    wl_display_terminate(wl_display_get_event_loop(
        wl_display_create()));
    exit(0);
}

int main(int argc, char *argv[]) {
    wlr_log_init(WLR_INFO, NULL);
    
    struct aether_server server = {0};
    
    // Create display
    server.wl_display = wl_display_create();
    if (!server.wl_display) {
        fprintf(stderr, "Failed to create display\n");
        return 1;
    }
    
    // Create backend
    server.backend = wlr_backend_autocreate(wl_display_get_event_loop(server.wl_display), NULL);
    if (!server.backend) {
        fprintf(stderr, "Failed to create backend\n");
        return 1;
    }
    
    // Create renderer
    server.renderer = wlr_renderer_autocreate(server.backend);
    if (!server.renderer) {
        fprintf(stderr, "Failed to create renderer\n");
        return 1;
    }
    
    wlr_renderer_init_wl_display(server.renderer, server.wl_display);
    
    // Create allocator
    server.allocator = wlr_allocator_autocreate(server.backend, server.renderer);
    if (!server.allocator) {
        fprintf(stderr, "Failed to create allocator\n");
        return 1;
    }
    
    // Create compositor
    server.compositor = wlr_compositor_create(server.wl_display, 5, server.renderer);
    
    // Create output layout
    server.output_layout = wlr_output_layout_create(server.wl_display);
    
    // Create scene
    server.scene = wlr_scene_create();
    server.scene_layout = wlr_scene_attach_output_layout(server.scene, server.output_layout);
    
    // Create xdg shell
    server.xdg_shell = wlr_xdg_shell_create(server.wl_display, 3);
    
    // Create seat
    server.seat = wlr_seat_create(server.wl_display, "seat0");
    
    // Create data device manager
    wlr_data_device_manager_create(server.wl_display);
    
    // Setup listeners
    server.new_output.notify = handle_new_output;
    wl_signal_add(&server.backend->events.new_output, &server.new_output);
    
    server.new_xdg_surface.notify = handle_new_xdg_surface;
    wl_signal_add(&server.xdg_shell->events.new_surface, &server.new_xdg_surface);
    
    // Start backend
    if (!wlr_backend_start(server.backend)) {
        fprintf(stderr, "Failed to start backend\n");
        wl_display_destroy(server.wl_display);
        return 1;
    }
    
    // Setup signal handlers
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);
    
    // Add socket
    const char *socket = wl_display_add_socket_auto(server.wl_display);
    if (!socket) {
        fprintf(stderr, "Failed to add socket\n");
        wlr_backend_destroy(server.backend);
        return 1;
    }
    
    printf("Aether OS Compositor started on WAYLAND_DISPLAY=%s\n", socket);
    setenv("WAYLAND_DISPLAY", socket, true);
    
    // Run event loop
    wl_display_run(server.wl_display);
    
    // Cleanup
    wl_display_destroy(server.wl_display);
    return 0;
}