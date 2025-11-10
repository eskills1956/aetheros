# Aether OS System Resources

This directory contains system-wide resources including themes, icons, fonts, and wallpapers.

## Directory Structure

```
resources/
├── themes/         # System themes
│   ├── default/   # Default light theme
│   └── dark/      # Dark theme
├── icons/         # System and app icons
│   ├── system/   # System UI icons
│   └── apps/     # Application icons
├── fonts/         # System fonts
├── wallpapers/    # Default wallpapers
└── README.md
```

## Themes

Themes define the visual appearance of the system including colors, typography, and animations.

### Default Theme

Located in `themes/default/`, provides a clean, light interface following Material Design principles.

**Key Features:**
- Blue primary color (#2196F3)
- Orange accent color (#FF5722)
- High contrast text
- Subtle animations

### Dark Theme

Located in `themes/dark/`, provides a dark interface optimized for low-light conditions.

**Key Features:**
- True black backgrounds (#000000)
- Reduced contrast for comfort
- OLED-optimized colors
- Power-saving on OLED displays

### Creating Custom Themes

1. Copy the default theme directory:
   ```bash
   cp -r resources/themes/default resources/themes/mytheme
   ```

2. Edit `theme.conf`:
   ```ini
   [Theme]
   Name=My Custom Theme
   Author=Your Name
   Version=1.0

   [Colors]
   Primary=#Your_Color
   # ... other colors
   ```

3. Build and install:
   ```bash
   aether-build system
   aether-flash --system
   ```

## Icons

System icons are provided in SVG format with PNG exports for multiple densities.

See `icons/README.md` for detailed guidelines.

### Icon Densities

- **mdpi** (1x) - 160 dpi
- **hdpi** (1.5x) - 240 dpi
- **xhdpi** (2x) - 320 dpi
- **xxhdpi** (3x) - 480 dpi
- **xxxhdpi** (4x) - 640 dpi

## Fonts

System fonts should be placed in the `fonts/` directory.

### Recommended Fonts

- **Roboto**: Primary UI font (sans-serif)
- **Roboto Mono**: Monospace font for code
- **Noto Sans**: International language support

### Adding Fonts

1. Place TrueType (.ttf) or OpenType (.otf) files in `fonts/`
2. Update font configuration in `config/system/fonts.conf`
3. Rebuild system to include fonts

## Wallpapers

Default wallpapers are stored in `wallpapers/` directory.

### Wallpaper Requirements

- **Resolution**: 1080x1920 minimum (portrait)
- **Format**: JPEG or PNG
- **Size**: <2MB per wallpaper
- **Aspect Ratio**: 16:9 or 18:9

### Naming Convention

```
wallpaper_<theme>_<variant>.jpg

Examples:
- wallpaper_default_01.jpg
- wallpaper_abstract_blue.jpg
- wallpaper_landscape_mountain.jpg
```

## Resource Compilation

Resources are compiled during the build process:

```bash
# Build all resources
aether-build system

# Resources are packaged in:
out/staging/system/share/resources/
```

## Runtime Resource Access

System services and applications access resources through standard paths:

```c
// C/C++ code
#define RESOURCE_PATH "/system/share/resources"
#define THEME_PATH RESOURCE_PATH "/themes/default"
#define ICON_PATH RESOURCE_PATH "/icons/system"
```

```dart
// Flutter/Dart code
const String resourcePath = '/system/share/resources';
const String themePath = '$resourcePath/themes/default';
const String iconPath = '$resourcePath/icons/system';
```

## Theme Switching

Users can switch themes through Settings or programmatically:

```bash
# Set system theme
aether-dev shell
$ setprop persist.aetheros.theme dark
$ reboot
```

## Asset Optimization

Resources are optimized during build:

- PNG images are compressed with pngcrush
- SVG files are minified
- Unused resources are stripped

## Localization

Resource strings support localization:

```
resources/strings/
├── values/           # Default (English)
├── values-es/        # Spanish
├── values-fr/        # French
└── values-de/        # German
```

## License

System resources are licensed under Apache 2.0 License unless otherwise specified.

Third-party resources (fonts, icons) retain their original licenses.

## Contributing

When contributing resources:

1. Follow naming conventions
2. Provide multiple densities for icons
3. Test in both light and dark themes
4. Optimize file sizes
5. Update documentation
6. Include license information
