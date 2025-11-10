# External Dependencies

This directory contains external third-party projects and libraries used by Aether OS.

## Directory Structure

```
external/
├── flutter/        # Flutter engine and embedder
├── wayland/        # Wayland compositor libraries
├── pipewire/       # PipeWire audio server
└── README.md
```

## Purpose

External dependencies include:

1. **Flutter Engine**: Rendering engine for applications
2. **Wayland**: Display server protocol
3. **PipeWire**: Modern audio/video server
4. **Other Libraries**: Additional third-party dependencies

## Adding External Dependencies

### 1. As Git Submodules

```bash
cd external/
git submodule add https://github.com/flutter/flutter flutter
git submodule add https://gitlab.freedesktop.org/wayland/wayland wayland
```

### 2. As Downloaded Archives

```bash
cd external/
wget https://example.com/library-1.0.tar.gz
tar xzf library-1.0.tar.gz
mv library-1.0 library
```

### 3. As Prebuilt Binaries

```bash
mkdir -p external/library/prebuilt
# Copy prebuilt libraries
cp /path/to/library.so external/library/prebuilt/
```

## Integration

### Build System Integration

Add to main Makefile:

```makefile
# Build external dependencies
external-deps:
	$(MAKE) -C external/flutter
	$(MAKE) -C external/wayland
	$(MAKE) -C external/pipewire
```

### CMake Integration

Create `external/CMakeLists.txt`:

```cmake
# External dependencies
add_subdirectory(flutter)
add_subdirectory(wayland)
add_subdirectory(pipewire)
```

## Flutter Integration

### Flutter Engine

The Flutter engine provides the runtime for Flutter applications.

**Location**: `external/flutter/`

**Building**:
```bash
cd external/flutter
gclient sync
./tools/gn --runtime-mode=release --target-os=linux --linux-cpu=arm64
ninja -C out/linux_release_arm64
```

**Integration**:
```makefile
FLUTTER_ENGINE := external/flutter/out/linux_release_arm64/libflutter_engine.so
```

## Wayland Integration

### Wayland Protocol

Wayland provides the display server protocol.

**Location**: `external/wayland/`

**Building**:
```bash
cd external/wayland
meson build
ninja -C build
```

**Dependencies**:
- libffi
- expat
- libxml2

## PipeWire Integration

### PipeWire Audio Server

PipeWire provides modern audio/video routing.

**Location**: `external/pipewire/`

**Building**:
```bash
cd external/pipewire
meson build -Daudioconvert=enabled -Dvideoconvert=enabled
ninja -C build
```

**Dependencies**:
- GStreamer
- ALSA
- BlueZ

## Dependency Management

### Version Pinning

Pin specific versions in `external/versions.conf`:

```ini
[flutter]
version=3.16.0
commit=68bfaea224bc794b3fc35ab90730eb3dcea7cf30

[wayland]
version=1.22.0
commit=b8a43f8e9331ee4a9b4e8e7e3f5a43f45b72e60d

[pipewire]
version=0.3.80
commit=5f4e3f5e6f9c2e3d4c5b6a7f8e9d0c1b2a3f4e5
```

### Update Script

Create `external/update.sh`:

```bash
#!/bin/bash
# Update external dependencies

cd "$(dirname "$0")"

# Update submodules
git submodule update --remote

# Or download specific versions
# wget -O flutter.tar.gz <url>
# tar xzf flutter.tar.gz
```

## Licensing

External dependencies retain their original licenses:

- **Flutter**: BSD 3-Clause License
- **Wayland**: MIT License
- **PipeWire**: MIT License

### License Compliance

1. Include LICENSE files from upstream
2. Document licenses in NOTICE file
3. Provide source code for GPL dependencies
4. Comply with attribution requirements

## Patching External Dependencies

### Creating Patches

```bash
cd external/library
# Make changes
git diff > ../../patches/library-fix.patch
```

### Applying Patches

```bash
cd external/library
patch -p1 < ../../patches/library-fix.patch
```

### Patch Directory

```
patches/
├── flutter/
│   └── 0001-aetheros-integration.patch
├── wayland/
│   └── 0001-custom-protocol.patch
└── pipewire/
    └── 0001-mobile-optimization.patch
```

## Cross-Compilation

### ARM64 Cross-Compilation

```bash
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig

cd external/library
./configure --host=aarch64-linux-gnu
make
```

### CMake Cross-Compilation

Create `toolchain-arm64.cmake`:

```cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
```

## Troubleshooting

### Missing Dependencies

```bash
# Install build dependencies
sudo apt-get install \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    libffi-dev \
    libexpat1-dev
```

### Build Failures

1. Check dependency versions
2. Verify toolchain setup
3. Review build logs
4. Check for conflicting libraries

### Runtime Issues

1. Verify library paths (LD_LIBRARY_PATH)
2. Check symbol conflicts (nm, ldd)
3. Validate ABI compatibility

## Security

### Vulnerability Scanning

```bash
# Scan for known vulnerabilities
tools/scan-vulnerabilities.sh external/
```

### Regular Updates

1. Monitor upstream security advisories
2. Update to patched versions
3. Test after updates
4. Document changes in CHANGELOG

## Contributing

When adding external dependencies:

1. Justify the dependency
2. Consider alternatives
3. Check license compatibility
4. Document integration
5. Provide build instructions
6. Test cross-platform builds

## References

- Flutter: https://flutter.dev
- Wayland: https://wayland.freedesktop.org
- PipeWire: https://pipewire.org
- License Guide: https://opensource.org/licenses
