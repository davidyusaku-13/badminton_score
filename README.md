# Badminton Score Keeper

A professional Flutter application designed for local badminton communities. Track scores with style, ease, and all the features players actually need.

## 🏸 Features

### Core Functionality
- **Large Score Display** - 220px Poppins font with Material Design elevation
- **Touch-Friendly Buttons** - Optimized for quick gameplay 
- **Instant Score Tracking** - Tap to increment, minus buttons to decrement
- **Sound Feedback** - Audio beep on score increments (toggleable)

### Smart Controls  
- **Hold-to-Reset** - Long press the hamburger button for instant score reset
- **Sound Toggle** - Turn audio on/off via hamburger menu
- **Haptic Feedback** - Vibration confirms actions

### Theme System
- **7 Beautiful Themes** - Dark, Light, Sunset, Forest, Ocean, Neon, Minimal
- **Swipe to Switch** - Swipe left/right on score area to change themes
- **High Contrast** - All themes optimized for readability
- **Material Design** - Modern elevated buttons and clean interface

### User Experience
- **Screen Always On** - No interruptions during matches
- **Landscape Optimized** - Both left and right orientations supported
- **SafeArea** - Respects Android status/navigation bars
- **Custom Typography** - Poppins font throughout for premium feel

## 🚀 Installation

### Prerequisites
- Flutter SDK (>=3.6.0)
- Android device or emulator
- USB debugging enabled (for direct install)

### Quick Start
```bash
# Get dependencies
flutter pub get

# Generate icons and splash screen
dart run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# Install to connected device
flutter install --release
```

### Building APK
```bash
# Optimized release build (~19MB)
flutter build apk --release --shrink

# For Google Play Store
flutter build appbundle --release
```

### Building for iOS
**Prerequisites (macOS only):**
- Xcode installed from App Store
- `flutter doctor` showing iOS toolchain ready

```bash
# Build iOS app
flutter build ios --release

# Build iOS app bundle for App Store
flutter build ipa --release
```

## 🎨 Themes

**Choose from 7 carefully crafted themes:**

1. **Dark** - High contrast purple/cyan on dark background
2. **Light** - Clean black/grey on white background  
3. **Sunset** - Warm orange/yellow on deep purple
4. **Forest** - Natural green/blue on dark forest green
5. **Ocean** - Bright cyan/blue on deep navy
6. **Neon** - Electric colors on dark backgrounds
7. **Minimal** - Subtle greys on pure white

**Switch themes:** Swipe left/right on score area or use hamburger menu

## 🎮 Controls

### Score Buttons
- **Tap large score areas** - Increment score with sound
- **Tap minus buttons** - Decrement score (silent)

### Hamburger Menu (⋮)
- **Single tap** - Open menu (Reset Score, Change Theme, Sound Toggle)
- **Long press** - Instant reset with haptic feedback

### Gesture Controls  
- **Swipe right** on score area - Previous theme
- **Swipe left** on score area - Next theme

## 🛠 Technical Details

### Architecture
- **Single-file design** with clean separation of concerns
- **Material Design 3** principles with proper elevation
- **Optimized performance** with FittedBox text scaling
- **Memory efficient** with minimal dependencies

### Key Dependencies
- `audioplayers: ^6.4.0` - Sound effects
- `wakelock_plus: ^1.2.5` - Keep screen awake

### App Size
- **Release APK**: ~19MB (optimized with font trimming)
- **Supports**: Android, iOS, Web, Windows, Linux, macOS

## 🏆 Perfect for Communities

Designed specifically for local badminton communities with features that matter:
- **No complex setup** - Just tap and play
- **Distraction-free** - Screen stays on, fullscreen landscape
- **Fast operation** - Quick reset, instant theme switching  
- **Reliable** - Works offline, no internet required
- **Accessible** - High contrast themes, large touch targets

## 📱 Compatibility

- **Android**: 5.0+ (API 21+)
- **Screen**: Optimized for landscape orientation
- **Size**: Works on phones and tablets
- **Performance**: Smooth on budget devices

---

**Built with ❤️ for badminton communities**