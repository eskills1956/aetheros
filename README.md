# Aether OS

A modern, lightweight mobile operating system built from scratch with a focus on performance, privacy, and user experience.

## Project Structure

```
aetheros/
├── src/                 # Source code
│   ├── kernel/         # Linux kernel (custom configured)
│   ├── bootloader/     # Boot components
│   ├── compositor/     # Wayland compositor
│   ├── system/         # System services
│   ├── frameworks/     # Application frameworks
│   ├── services/       # System services
│   └── apps/           # Pre-installed applications
├── build/              # Build system
├── out/                # Build output
├── sdk/                # Development SDK
├── device/             # Device-specific code
├── config/             # Configuration files
├── external/           # External dependencies
├── vendor/             # Vendor-specific code
├── tests/              # Test suites
├── docs/               # Documentation
├── tools/              # Development tools
├── resources/          # System resources
└── prebuilts/          # Prebuilt binaries
```

## Quick Start

1. **Setup Environment:**
   ```bash
   source build/envsetup.sh
   ```

2. **Configure Build:**
   ```bash
   lunch aetheros-eng
   ```

3. **Build System:**
   ```bash
   make aetheros -j$(nproc)
   ```

4. **Flash Device:**
   ```bash
   aether-flash
   ```

## Development

See [Developer Guide](docs/guides/developer-guide.md) for detailed instructions.

## License

Copyright (c) 2024 Aether OS Project
Licensed under the Apache License 2.0
