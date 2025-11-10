/**
 * Default Audio HAL Implementation
 *
 * This is a reference implementation that can be overridden
 * by vendor-specific implementations
 */

#include "audio_hal.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Default configuration
static audio_config_t default_config = {
    .sample_rate = AUDIO_SAMPLE_RATE_48000,
    .channel_count = AUDIO_CHANNEL_STEREO,
    .format = AUDIO_FORMAT_PCM_16_BIT,
    .frame_count = 1024,
};

// Default audio state
static float master_volume = 0.5f;
static bool master_mute = false;

// Output stream implementation
static ssize_t output_stream_write(audio_output_stream_t* stream,
                                   const void* buffer, size_t bytes) {
    // Default: no-op (would write to ALSA/PipeWire in real implementation)
    return bytes;
}

static int output_stream_get_presentation_position(audio_output_stream_t* stream,
                                                   uint64_t* frames) {
    // Default: return 0
    *frames = 0;
    return HAL_SUCCESS;
}

static int audio_stream_get_config(audio_stream_t* stream, audio_config_t* config) {
    memcpy(config, &default_config, sizeof(audio_config_t));
    return HAL_SUCCESS;
}

static int audio_stream_set_config(audio_stream_t* stream, const audio_config_t* config) {
    memcpy(&default_config, config, sizeof(audio_config_t));
    return HAL_SUCCESS;
}

static int audio_stream_start(audio_stream_t* stream) {
    printf("[AudioHAL] Stream started\n");
    return HAL_SUCCESS;
}

static int audio_stream_stop(audio_stream_t* stream) {
    printf("[AudioHAL] Stream stopped\n");
    return HAL_SUCCESS;
}

static size_t audio_stream_get_buffer_size(audio_stream_t* stream) {
    return default_config.frame_count * default_config.channel_count * 2; // 16-bit samples
}

// Device implementation
static int audio_set_master_volume(audio_hal_device_t* dev, float volume) {
    if (volume < 0.0f || volume > 1.0f) {
        return HAL_ERROR_BAD_VALUE;
    }
    master_volume = volume;
    printf("[AudioHAL] Master volume set to: %.2f\n", volume);
    return HAL_SUCCESS;
}

static int audio_get_master_volume(audio_hal_device_t* dev, float* volume) {
    *volume = master_volume;
    return HAL_SUCCESS;
}

static int audio_set_master_mute(audio_hal_device_t* dev, bool muted) {
    master_mute = muted;
    printf("[AudioHAL] Master mute: %s\n", muted ? "on" : "off");
    return HAL_SUCCESS;
}

static int audio_get_master_mute(audio_hal_device_t* dev, bool* muted) {
    *muted = master_mute;
    return HAL_SUCCESS;
}

static int audio_open_output_stream(audio_hal_device_t* dev,
                                   const audio_config_t* config,
                                   audio_output_stream_t** stream) {
    audio_output_stream_t* out = calloc(1, sizeof(audio_output_stream_t));
    if (!out) {
        return HAL_ERROR_NO_MEMORY;
    }

    // Initialize stream functions
    out->stream.get_config = audio_stream_get_config;
    out->stream.set_config = audio_stream_set_config;
    out->stream.start = audio_stream_start;
    out->stream.stop = audio_stream_stop;
    out->stream.get_buffer_size = audio_stream_get_buffer_size;
    out->write = output_stream_write;
    out->get_presentation_position = output_stream_get_presentation_position;

    *stream = out;
    printf("[AudioHAL] Output stream opened\n");
    return HAL_SUCCESS;
}

static void audio_close_output_stream(audio_hal_device_t* dev,
                                     audio_output_stream_t* stream) {
    printf("[AudioHAL] Output stream closed\n");
    free(stream);
}

static int audio_open_input_stream(audio_hal_device_t* dev,
                                  const audio_config_t* config,
                                  audio_input_stream_t** stream) {
    audio_input_stream_t* in = calloc(1, sizeof(audio_input_stream_t));
    if (!in) {
        return HAL_ERROR_NO_MEMORY;
    }

    // Initialize stream functions
    in->stream.get_config = audio_stream_get_config;
    in->stream.set_config = audio_stream_set_config;
    in->stream.start = audio_stream_start;
    in->stream.stop = audio_stream_stop;
    in->stream.get_buffer_size = audio_stream_get_buffer_size;

    *stream = in;
    printf("[AudioHAL] Input stream opened\n");
    return HAL_SUCCESS;
}

static void audio_close_input_stream(audio_hal_device_t* dev,
                                    audio_input_stream_t* stream) {
    printf("[AudioHAL] Input stream closed\n");
    free(stream);
}

static int audio_device_close(hal_device_t* device) {
    audio_hal_device_t* audio_dev = (audio_hal_device_t*)device;
    free(audio_dev);
    printf("[AudioHAL] Device closed\n");
    return HAL_SUCCESS;
}

// Module implementation
static hal_module_t audio_module = {
    .api_version = HAL_API_VERSION,
    .id = HAL_MODULE_AUDIO,
    .name = "Aether Audio HAL",
    .author = "Aether OS Project",
    .module_version = 1,
};

int audio_hal_open(audio_hal_device_t** device) {
    audio_hal_device_t* dev = calloc(1, sizeof(audio_hal_device_t));
    if (!dev) {
        return HAL_ERROR_NO_MEMORY;
    }

    // Initialize device
    dev->device.module = &audio_module;
    dev->device.version = 1;
    dev->device.id = "default";
    dev->device.name = "Default Audio Device";
    dev->device.close = audio_device_close;

    // Initialize functions
    dev->set_master_volume = audio_set_master_volume;
    dev->get_master_volume = audio_get_master_volume;
    dev->set_master_mute = audio_set_master_mute;
    dev->get_master_mute = audio_get_master_mute;
    dev->open_output_stream = audio_open_output_stream;
    dev->close_output_stream = audio_close_output_stream;
    dev->open_input_stream = audio_open_input_stream;
    dev->close_input_stream = audio_close_input_stream;

    *device = dev;
    printf("[AudioHAL] Device opened\n");
    return HAL_SUCCESS;
}
