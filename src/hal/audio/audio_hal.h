/**
 * Audio HAL Interface
 */

#ifndef AETHER_AUDIO_HAL_H
#define AETHER_AUDIO_HAL_H

#include "../hal.h"

#ifdef __cplusplus
extern "C" {
#endif

// Audio formats
#define AUDIO_FORMAT_PCM_16_BIT   0x1
#define AUDIO_FORMAT_PCM_24_BIT   0x2
#define AUDIO_FORMAT_PCM_32_BIT   0x3
#define AUDIO_FORMAT_PCM_FLOAT    0x4

// Audio channels
#define AUDIO_CHANNEL_MONO    0x1
#define AUDIO_CHANNEL_STEREO  0x2

// Sample rates
#define AUDIO_SAMPLE_RATE_8000   8000
#define AUDIO_SAMPLE_RATE_16000  16000
#define AUDIO_SAMPLE_RATE_44100  44100
#define AUDIO_SAMPLE_RATE_48000  48000

/**
 * Audio configuration
 */
typedef struct audio_config {
    uint32_t sample_rate;
    uint32_t channel_count;
    uint32_t format;
    uint32_t frame_count;
} audio_config_t;

/**
 * Audio stream
 */
typedef struct audio_stream {
    /** Common device */
    hal_device_t device;

    /** Get audio configuration */
    int (*get_config)(struct audio_stream* stream, audio_config_t* config);

    /** Set audio configuration */
    int (*set_config)(struct audio_stream* stream, const audio_config_t* config);

    /** Start stream */
    int (*start)(struct audio_stream* stream);

    /** Stop stream */
    int (*stop)(struct audio_stream* stream);

    /** Get buffer size */
    size_t (*get_buffer_size)(struct audio_stream* stream);
} audio_stream_t;

/**
 * Audio output stream
 */
typedef struct audio_output_stream {
    audio_stream_t stream;

    /** Write audio data */
    ssize_t (*write)(struct audio_output_stream* stream, const void* buffer, size_t bytes);

    /** Get presentation position */
    int (*get_presentation_position)(struct audio_output_stream* stream, uint64_t* frames);
} audio_output_stream_t;

/**
 * Audio input stream
 */
typedef struct audio_input_stream {
    audio_stream_t stream;

    /** Read audio data */
    ssize_t (*read)(struct audio_input_stream* stream, void* buffer, size_t bytes);
} audio_input_stream_t;

/**
 * Audio HAL device
 */
typedef struct audio_hal_device {
    hal_device_t device;

    /** Set master volume (0.0 - 1.0) */
    int (*set_master_volume)(struct audio_hal_device* dev, float volume);

    /** Get master volume */
    int (*get_master_volume)(struct audio_hal_device* dev, float* volume);

    /** Set master mute */
    int (*set_master_mute)(struct audio_hal_device* dev, bool muted);

    /** Get master mute */
    int (*get_master_mute)(struct audio_hal_device* dev, bool* muted);

    /** Open output stream */
    int (*open_output_stream)(struct audio_hal_device* dev,
                              const audio_config_t* config,
                              audio_output_stream_t** stream);

    /** Close output stream */
    void (*close_output_stream)(struct audio_hal_device* dev,
                                audio_output_stream_t* stream);

    /** Open input stream */
    int (*open_input_stream)(struct audio_hal_device* dev,
                             const audio_config_t* config,
                             audio_input_stream_t** stream);

    /** Close input stream */
    void (*close_input_stream)(struct audio_hal_device* dev,
                               audio_input_stream_t* stream);
} audio_hal_device_t;

#ifdef __cplusplus
}
#endif

#endif // AETHER_AUDIO_HAL_H
