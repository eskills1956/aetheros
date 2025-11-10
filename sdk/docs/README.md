# Aether OS SDK

Welcome to the Aether OS Software Development Kit (SDK)!

## Overview

The Aether OS SDK provides tools, libraries, and documentation for building applications for the Aether OS mobile platform.

## Getting Started

### Setup

1. Set the SDK environment variable:
   ```bash
   export AETHEROS_SDK=/path/to/sdk
   export PATH=$AETHEROS_SDK/tools:$PATH
   ```

2. Create a new application:
   ```bash
   aether-create flutter my-app
   # or
   aether-create native my-app
   ```

3. Build your application:
   ```bash
   cd my-app
   aether-build
   ```

4. Package your application:
   ```bash
   aether-package
   ```

## SDK Structure

- `tools/` - Development tools (aether-build, aether-create, aether-package)
- `libs/` - System libraries (libaether.so, etc.)
- `include/` - Header files for native development
- `templates/` - Project templates
- `docs/` - Documentation
- `examples/` - Example applications

## API Reference

### System APIs

- `aether_get_battery()` - Get battery level (0-100)
- `aether_get_signal()` - Get signal strength (0-4)
- `aether_set_brightness(level)` - Set screen brightness (0-100)
- `aether_set_volume(level)` - Set system volume (0-100)

See `include/aetheros/aether.h` for complete API documentation.

## Flutter Development

Aether OS fully supports Flutter for application development. Use the standard Flutter tools with the Aether OS SDK.

## Native Development

For native C/C++ applications, link against `libaether.so` and include the Aether OS headers.

Example CMakeLists.txt:
```cmake
include_directories(${AETHEROS_SDK}/include)
link_directories(${AETHEROS_SDK}/libs)
target_link_libraries(myapp aether)
```

## Support

For issues and questions, please visit:
https://github.com/aetheros/sdk/issues

## License

Copyright (c) 2024 Aether OS Project
Licensed under the Apache License 2.0
