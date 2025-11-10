# Aether OS Icons

This directory contains system and application icons.

## Directory Structure

```
icons/
├── system/          # System UI icons
│   ├── battery/    # Battery status icons
│   ├── network/    # Network/WiFi icons
│   ├── bluetooth/  # Bluetooth icons
│   └── settings/   # Settings and control icons
├── apps/           # Application launcher icons
└── README.md
```

## Icon Guidelines

### Sizes

System icons should be provided in multiple densities:

- **mdpi**: 24x24dp (1x baseline)
- **hdpi**: 36x36dp (1.5x)
- **xhdpi**: 48x48dp (2x)
- **xxhdpi**: 72x72dp (3x)
- **xxxhdpi**: 96x96dp (4x)

App launcher icons:

- **mdpi**: 48x48dp
- **hdpi**: 72x72dp
- **xhdpi**: 96x96dp
- **xxhdpi**: 144x144dp
- **xxxhdpi**: 192x192dp

### Format

- Primary format: SVG (scalable vector graphics)
- Export format: PNG with transparency
- Color: Support both light and dark themes

### Naming Convention

```
ic_<category>_<name>_<state>.svg

Examples:
- ic_battery_full.svg
- ic_battery_low.svg
- ic_wifi_signal_4.svg
- ic_bluetooth_connected.svg
- ic_settings_general.svg
```

### Design Principles

1. **Simple and Clear**: Icons should be immediately recognizable
2. **Consistent Style**: Follow Material Design guidelines
3. **Minimal Detail**: Use simple shapes and minimal details
4. **Optical Alignment**: Visually balanced, not mathematically centered
5. **Theme Support**: Provide versions for light and dark themes

## System Icons

### Battery Icons
- ic_battery_0.svg - Empty
- ic_battery_25.svg - 25%
- ic_battery_50.svg - 50%
- ic_battery_75.svg - 75%
- ic_battery_100.svg - Full
- ic_battery_charging.svg - Charging indicator

### Network Icons
- ic_wifi_0.svg - No signal
- ic_wifi_1.svg - Weak signal
- ic_wifi_2.svg - Fair signal
- ic_wifi_3.svg - Good signal
- ic_wifi_4.svg - Excellent signal
- ic_wifi_off.svg - WiFi disabled

### Bluetooth Icons
- ic_bluetooth.svg - Bluetooth enabled
- ic_bluetooth_connected.svg - Device connected
- ic_bluetooth_disabled.svg - Bluetooth disabled

### Control Icons
- ic_brightness_auto.svg
- ic_brightness_high.svg
- ic_brightness_low.svg
- ic_brightness_medium.svg
- ic_volume_up.svg
- ic_volume_down.svg
- ic_volume_mute.svg

## Generating Icons

Use the icon generation tool:

```bash
# Generate all icon sizes from SVG
tools/generate-icons.sh resources/icons/system/ic_battery_full.svg

# Generate for specific density
tools/generate-icons.sh resources/icons/system/ic_battery_full.svg xxhdpi
```

## Third-Party Icon Sets

Aether OS uses icons from:

- Material Design Icons (Apache 2.0 License)
- Remix Icon (Apache 2.0 License)

## Contributing

When adding new icons:

1. Create SVG source file
2. Follow naming conventions
3. Generate all densities
4. Test in both light and dark themes
5. Update this README with icon descriptions

## License

System icons are licensed under Apache 2.0 License.
