# Aether OS Developer Guide

## Getting Started

### Prerequisites
- Ubuntu 20.04+ or similar Linux distribution
- 16GB RAM minimum (32GB recommended)
- 200GB free disk space
- Git, Python 3, Make, GCC

### Setup Development Environment

1. Clone the repository:
```bash
git clone https://github.com/yourusername/aetheros.git
cd aetheros
```

2. Install dependencies:
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential git curl wget \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
    cmake ninja-build meson \
    libwayland-dev libwlroots-dev \
    flutter
```

3. Setup build environment:
```bash
source build/envsetup.sh
```

4. Configure build target:
```bash
lunch aetheros_arm64-eng
```

5. Build the system:
```bash
make aetheros -j$(nproc)
```

## Project Structure

- `src/` - Source code
- `build/` - Build system and scripts
- `out/` - Build output
- `device/` - Device-specific configurations
- `sdk/` - Development SDK
- `docs/` - Documentation

## Building Components

### Kernel
```bash
cd src/kernel
make aetheros_defconfig
make -j$(nproc)
```

### System Services
```bash
cd src/system
make all
```

### Applications
```bash
cd src/apps/launcher
flutter build linux --release
```

## Testing

Run unit tests:
```bash
make test
```

Run integration tests:
```bash
make test-integration
```

## Contributing

Please read [CONTRIBUTING.md](../CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.
