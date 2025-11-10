# Launcher Assets

This directory contains assets for the Aether OS Launcher application.

## Directory Structure

- `images/` - Background images, wallpapers, and other graphics
- `icons/` - App icons and UI icons

## Required Assets

### Images
- `wallpaper_default.png` - Default wallpaper
- `logo.png` - Aether OS logo

### Icons
App icons for preinstalled apps (PNG format, 192x192px recommended):
- `phone.png`
- `messages.png`
- `browser.png`
- `camera.png`
- `gallery.png`
- `settings.png`
- `files.png`
- `music.png`
- `store.png`
- `weather.png`
- `clock.png`
- `calculator.png`

## Adding Assets

1. Place image files in the appropriate directory
2. Update `pubspec.yaml` if adding new asset paths
3. Reference in Dart code using `AssetImage('assets/images/filename.png')`

## Current Status

**Placeholder**: This directory currently contains only documentation.
Asset files should be added during UI implementation phase.

For development/testing, the launcher will use:
- Material Design icons (via Flutter's built-in icons)
- Colored containers as placeholders for wallpapers
- Gradient backgrounds instead of images
