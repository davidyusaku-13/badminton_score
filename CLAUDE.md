# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A professional Flutter badminton score keeper application designed for local community use. Features a clean Material Design interface with advanced gesture controls, multiple themes, and community-focused functionality. The app is optimized for landscape mobile devices with emphasis on simplicity and reliability.

## Architecture Summary

### Single-File Architecture (lib/main.dart)
The entire application is contained in one well-organized file with clear separation of concerns:

**Core Classes:**
- `AppConstants` - UI dimensions, font sizes, layout constants
- `ThemeKeys` - String constants for theme names with default
- `AppThemes` - Theme definitions with Material Design color schemes
- `ThemeColors` - Data class for theme configuration
- `BadmintonScoreApp` - Root widget managing global theme state
- `ScoreScreen` - Main UI with modular widget architecture

**Widget Architecture:**
- `_buildScoreSection()` - Top score display area (75% height) with swipe gestures
- `_buildControlSection()` - Bottom control buttons (25% height)
- `_buildMenuButton()` - Custom hamburger menu with tap/long-press handling
- `_buildScoreButton()` - Material Design score buttons with elevation
- `_buildControlButton()` - Outlined control buttons for minus actions
- `_buildGridItem()` - Consistent padding wrapper

## Key Features Implementation

### Theme System
- **7 Themes**: Dark, Light, Sunset, Forest, Ocean, Neon, Minimal
- **Swipe Navigation**: Horizontal swipes on score area cycle through themes
- **High Contrast**: All themes optimized for WCAG accessibility
- **Material Colors**: Primary, secondary, surface, onSurface, accent pattern

### Advanced Controls
- **Tap Score Areas**: Increment with sound feedback
- **Minus Buttons**: Decrement scores (silent)
- **Hamburger Menu**: Single tap opens menu, long press instant resets
- **Sound Toggle**: Menu option to enable/disable audio
- **Haptic Feedback**: Confirms theme changes and quick resets

### User Experience Features
- **Screen Always On**: `wakelock_plus` prevents screen timeout
- **SafeArea**: Respects Android status/navigation bars
- **Landscape Lock**: Both left and right orientations supported
- **FittedBox Text**: All text scales properly to prevent overflow
- **Sound Failsafe**: Audio stops on any non-score button press

## Development Commands

### Essential Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run on connected device
- `dart run flutter_launcher_icons` - Generate app icons
- `flutter pub run flutter_native_splash:create` - Generate splash screen
- `flutter install --release` - Install optimized build to device

### Build Commands
- `flutter build apk --release --shrink` - Optimized APK (~19MB)
- `flutter build appbundle --release` - Google Play Store bundle
- `flutter analyze` - Static analysis
- `dart format .` - Code formatting

### Testing
- `flutter test` - Run unit tests (widget_test.dart)
- No additional test framework required

## Dependencies (Minimal & Optimized)

### Core Dependencies
- `audioplayers: ^6.4.0` - Sound effects for score increments
- `wakelock_plus: ^1.2.5` - Keep screen awake during matches

### Dev Dependencies  
- `flutter_lints: ^5.0.0` - Code analysis and linting
- `flutter_native_splash: ^2.3.7` - Splash screen generation
- `flutter_launcher_icons: 0.14.3` - App icon generation

### Removed Dependencies
- `provider` - Not needed for simple state management
- `cupertino_icons` - Not used in Material Design app

## Assets & Resources

### Fonts
- **Poppins Regular** (400) - Body text and numbers
- **Poppins SemiBold** (600) - Score display and buttons
- All other Poppins variants removed for size optimization

### Audio Assets
- `assets/beep.mp3` - Score increment sound effect

### Visual Assets
- `assets/splash.png` - App icon and splash screen image

## Code Style & Conventions

### Widget Naming
- Private methods prefixed with `_build` for UI components
- Descriptive parameter names with required annotations
- Consistent color parameter ordering: `color`, `textColor`

### State Management
- Simple `setState()` pattern for score and theme state
- Theme state managed at app level, passed down via callbacks
- Sound and UI state managed locally in ScoreScreen

### Material Design Implementation
- Proper elevation and shadows on score buttons
- Outlined button style for secondary actions
- Consistent border radius (12px) across all buttons
- WCAG compliant color contrast ratios

## Performance Optimizations

### Size Optimization
- Removed unused font variants (reduced 16 files to 2)
- Minimal dependency set
- Release build with shrinking enabled
- Final APK size: ~19MB

### Runtime Performance
- FittedBox prevents text overflow calculations
- Efficient gesture detection limited to score area
- Minimal widget rebuilds with focused setState calls
- Audio player properly disposed to prevent memory leaks

## Community-Focused Design Decisions

### Simplicity First
- No user accounts, cloud sync, or complex features
- Offline-first design with no internet requirements
- Single-purpose interface focused on score tracking

### Accessibility
- Large touch targets optimized for quick gameplay
- High contrast themes for various lighting conditions
- Haptic feedback confirms important actions
- Screen always-on prevents interruptions

### Local Use Optimization
- Fast theme switching for different court conditions
- Instant reset for quick game transitions
- Silent minus buttons to avoid audio conflicts
- Landscape orientation for natural holding position

## Future Maintenance Notes

### Adding New Themes
1. Add theme key to `ThemeKeys` class
2. Define colors in `AppThemes.themes` map
3. Ensure all 6 colors are defined: primary, secondary, surface, onSurface, accent, background
4. Test contrast ratios for accessibility

### Modifying UI Constants
- Update `AppConstants` class values
- FittedBox will handle text scaling automatically
- Test on different screen sizes after changes

### Code Organization
- Keep single-file structure for simplicity
- Use private methods for UI components
- Maintain consistent parameter ordering
- Follow Material Design principles for new features

This app represents a complete, polished solution for badminton community score tracking with professional-grade UI/UX and optimized performance.