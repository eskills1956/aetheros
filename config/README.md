# Aether OS Configuration Files

This directory contains system-wide configuration files for Aether OS.

## Directory Structure

```
config/
├── system/           # System configuration files
│   ├── default.conf       # Default system settings
│   ├── services.conf      # Services configuration
│   ├── display.conf       # Display and compositor settings
│   └── network.conf       # Network configuration
└── README.md
```

## Configuration Files

### system/default.conf

Contains default system-wide settings including:
- System name and version
- Default display brightness
- Default audio volume
- Power management thresholds
- Network defaults
- Security settings

### system/services.conf

Defines system services and their configuration:
- Core services list
- Startup order
- Service binaries location
- Auto-start and restart policies

### system/display.conf

Display and compositor configuration:
- Wayland compositor backend
- Screen resolution and DPI
- Graphics acceleration
- Rendering settings

### system/network.conf

Network configuration:
- WiFi settings
- Bluetooth settings
- Mobile data settings
- Hotspot configuration

## Usage

These configuration files are read by system services at startup. To modify system behavior:

1. Edit the appropriate configuration file
2. Restart the affected service or reboot the system

## File Format

Configuration files use INI format:
```ini
[Section]
Key=Value
```

Comments start with `#`
