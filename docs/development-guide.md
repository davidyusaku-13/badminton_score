# Development Guide

## Prerequisites

### Required Software

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Flutter SDK | 3.6.0 | Mobile app framework |
| Dart SDK | Included with Flutter | Programming language |
| Android Studio | Latest | Android development (optional but recommended) |
| Xcode | Latest | iOS development (macOS only) |
| Git | Any recent version | Version control |

### Platform-Specific Requirements

**Android Development:**
- Java Development Kit (JDK) 11 or higher
- Android SDK (installed via Android Studio)
- Android device or emulator
- USB debugging enabled on physical device

**iOS Development (macOS only):**
- Xcode (from Mac App Store)
- CocoaPods (installed automatically by Flutter)
- iOS device or simulator
- Apple Developer account (for device testing)

### Verification

Check your Flutter installation:

```bash
flutter doctor
```

Expected output should show:
- ✓ Flutter (Channel stable, 3.6.0 or higher)
- ✓ Android toolchain (if developing for Android)
- ✓ Xcode (if developing for iOS on macOS)
- ✓ Connected devices

## Environment Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd badminton_score
```

### 2. Install Dependencies

```bash
flutter pub get
```

This installs:
- `audioplayers: ^6.4.0` - Audio playback
- `wakelock_plus: ^1.2.5` - Screen wake lock
- `shared_preferences: ^2.3.3` - Local storage
- Development tools (lints, icon generator, splash screen generator)

### 3. Generate Assets

**App Icons:**
```bash
dart run flutter_launcher_icons
```

Generates app icons for Android and iOS from `assets/splash.png`.

**Splash Screen:**
```bash
flutter pub run flutter_native_splash:create
```

Generates native splash screens with green background (#4CAF50) and app icon.

### 4. Verify Setup

```bash
flutter run
```

This should launch the app on a connected device or emulator.

## Project Structure

```
badminton_score/
├── lib/
│   └── main.dart              # Complete application (1580 lines)
├── test/
│   └── widget_test.dart       # Widget tests
├── assets/
│   ├── fonts/                 # Poppins font family
│   ├── beep.mp3              # Score sound effect
│   └── splash.png            # App icon source
├── android/                   # Android platform code
├── ios/                       # iOS platform code
├── pubspec.yaml              # Project configuration
└── analysis_options.yaml     # Linter configuration
```

## Development Workflow

### Running the App

**Debug Mode (Hot Reload Enabled):**
```bash
flutter run
```

**Release Mode (Optimized):**
```bash
flutter run --release
```

**Specific Device:**
```bash
flutter devices                # List available devices
flutter run -d <device-id>     # Run on specific device
```

**Install Release Build:**
```bash
flutter install --release
```

### Hot Reload

While app is running in debug mode:
- Press `r` - Hot reload (preserves state)
- Press `R` - Hot restart (resets state)
- Press `q` - Quit

### Code Formatting

**Format All Files:**
```bash
dart format .
```

**Format Specific File:**
```bash
dart format lib/main.dart
```

**Check Formatting (CI/CD):**
```bash
dart format --output=none --set-exit-if-changed .
```

### Static Analysis

**Run Analyzer:**
```bash
flutter analyze
```

**Fix Auto-Fixable Issues:**
```bash
dart fix --apply
```

### Testing

**Run All Tests:**
```bash
flutter test
```

**Run Specific Test:**
```bash
flutter test test/widget_test.dart
```

**Test with Coverage:**
```bash
flutter test --coverage
```

Coverage report generated in `coverage/lcov.info`.

### Debugging

**Enable Debug Logging:**
```dart
// In lib/main.dart, debug prints are already present
debugPrint('Audio preload failed: $e');
```

**Flutter DevTools:**
```bash
flutter run
# Press 'w' to open DevTools in browser
```

DevTools provides:
- Widget inspector
- Performance profiler
- Memory profiler
- Network inspector
- Logging view

## Building for Production

### Android

**Build APK (Single File):**
```bash
flutter build apk --release --shrink
```

Output: `build/app/outputs/flutter-apk/app-release.apk` (~19 MB)

**Build App Bundle (Google Play):**
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**Build Split APKs (Per ABI):**
```bash
flutter build apk --release --split-per-abi
```

Generates separate APKs for arm64-v8a, armeabi-v7a, x86_64.

### iOS

**Build iOS App (Unsigned):**
```bash
flutter build ios --release --no-codesign
```

**Build IPA (Requires Signing):**
```bash
flutter build ipa --release
```

Requires:
- Apple Developer account
- Provisioning profile
- Code signing certificate

**Archive for App Store:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Product → Archive
3. Distribute App → App Store Connect

### Build Configuration

**Android Build Settings:**
- File: `android/app/build.gradle.kts`
- Package: `com.example.badminton_score`
- Min SDK: Defined by Flutter (typically API 21)
- Target SDK: Latest stable
- Java Version: 11

**iOS Build Settings:**
- File: `ios/Runner.xcodeproj`
- Bundle ID: `com.example.badmintonScore`
- Deployment Target: iOS 12.0+
- Language: Swift

## Common Development Tasks

### Adding a New Theme

1. **Define Theme Colors** (lib/main.dart:66-117)

```dart
'myNewTheme': ThemeColors(
  name: 'My Theme',
  background: Color(0xFFFFFFFF),
  primary: Color(0xFF2196F3),
  secondary: Color(0xFF03A9F4),
  surface: Color(0xFFE3F2FD),
  onSurface: Color(0xFF212121),
  accent: Color(0xFF1976D2),
  gamePoint: Color(0xFFFFD700),
),
```

2. **Test Theme**

Run app and swipe to navigate to new theme, or open menu → Change Theme.

3. **Verify Accessibility**

Check contrast ratios meet WCAG AA standards:
- Normal text: 4.5:1 minimum
- Large text: 3:1 minimum

### Modifying Game Rules

1. **Update Constants** (lib/main.dart:18-24)

```dart
static const int minTargetScore = 5;
static const int defaultTargetScore = 21;
static const int maxScoreOffset = 9;
static const int minWinMargin = 2;
```

2. **Update Win Detection Logic** (lib/main.dart:438-448)

```dart
bool _checkWin(int score, int opponentScore) {
  final dynamicMaxScore = targetScore + AppConstants.maxScoreOffset;
  if (score >= dynamicMaxScore) return true;
  if (score >= targetScore &&
      score - opponentScore >= AppConstants.minWinMargin) {
    return true;
  }
  return false;
}
```

3. **Update Tests** (test/widget_test.dart)

Add test cases for new rules.

### Adding Persistence

1. **Add State Variable** (lib/main.dart:306-315)

```dart
String myNewSetting = 'default';
```

2. **Load in initState** (lib/main.dart:366-386)

```dart
Future<void> _loadPreferences() async {
  final prefs = await _getPrefs();
  setState(() {
    myNewSetting = prefs.getString('myNewSetting') ?? 'default';
  });
}
```

3. **Save on Change** (lib/main.dart:388-400)

```dart
Future<void> _savePreferences() async {
  final prefs = await _getPrefs();
  await prefs.setString('myNewSetting', myNewSetting);
}
```

### Modifying UI Layout

1. **Update Layout Constants** (lib/main.dart:8-16)

```dart
static const int scoreSectionFlex = 75;  // 75% height
static const int controlSectionFlex = 25; // 25% height
static const double scoreTextSize = 256;
```

2. **Modify Builder Methods** (lib/main.dart:912-1180)

```dart
Widget _buildScoreSection(ThemeColors theme) {
  return Expanded(
    flex: AppConstants.scoreSectionFlex,
    child: // ... your layout
  );
}
```

3. **Test on Multiple Screen Sizes**

Use Flutter DevTools device emulation or physical devices.

### Adding Audio Feedback

1. **Add Audio File** to `assets/`

2. **Declare in pubspec.yaml**

```yaml
flutter:
  assets:
    - assets/my-sound.mp3
```

3. **Load and Play**

```dart
final source = AssetSource('my-sound.mp3');
await _player.play(source);
```

## Troubleshooting

### Common Issues

**Issue: "Flutter command not found"**
- Solution: Add Flutter to PATH
- Verify: `flutter doctor`

**Issue: "Gradle build failed"**
- Solution: Clean build cache
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Issue: "CocoaPods not installed" (iOS)**
- Solution: Install CocoaPods
```bash
sudo gem install cocoapods
cd ios
pod install
```

**Issue: "Hot reload not working"**
- Solution: Hot restart instead (press `R`)
- Or: Restart app completely

**Issue: "Audio not playing"**
- Check: Sound toggle in menu
- Check: Device volume
- Check: Asset declared in pubspec.yaml
- Debug: Look for error in console

**Issue: "Theme not persisting"**
- Check: SharedPreferences permissions
- Debug: Add logging to `_loadTheme()` and `changeTheme()`

**Issue: "App crashes on startup"**
- Check: All assets declared in pubspec.yaml
- Check: Font files exist in assets/fonts/
- Run: `flutter clean && flutter pub get`

### Performance Issues

**Slow Build Times:**
```bash
flutter clean
flutter pub get
```

**Large APK Size:**
- Use `--shrink` flag
- Remove unused assets
- Enable ProGuard/R8 (Android)

**Slow Hot Reload:**
- Reduce widget tree complexity
- Use `const` constructors where possible
- Avoid expensive operations in `build()`

### Debugging Tips

**Enable Verbose Logging:**
```bash
flutter run -v
```

**Check Device Logs:**

Android:
```bash
adb logcat
```

iOS:
```bash
idevicesyslog
```

**Profile Performance:**
```bash
flutter run --profile
# Press 'P' to open performance overlay
```

**Inspect Widget Tree:**
```bash
flutter run
# Press 'w' to open DevTools
# Navigate to Widget Inspector
```

## Code Quality

### Linting Rules

Configuration: `analysis_options.yaml`

**Enabled Rules:**
- Base rules from `package:flutter_lints/flutter.yaml`
- `unnecessary_breaks: true`

**Disabled Rules:**
- `avoid_print: false` - Print statements allowed
- `prefer_const_constructors: false` - Not enforced
- `prefer_final_fields: false` - Mutable fields allowed
- `use_key_in_widget_constructors: false` - Keys not required

### Code Style Guidelines

**Naming Conventions:**
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `camelCase` with `static const`
- Private members: `_leadingUnderscore`

**Widget Builders:**
- Prefix with `_build`: `_buildScoreButton()`
- Accept parameters for customization
- Return Widget type

**State Management:**
- Use `setState()` for local state
- Use callbacks for parent communication
- Keep state minimal and focused

**Error Handling:**
- Use try-catch for async operations
- Provide fallback values
- Log errors with `debugPrint()`
- Continue gracefully on non-critical errors

### Testing Guidelines

**Widget Tests:**
- Test user interactions
- Verify UI updates
- Check state changes
- Validate win conditions

**Test Structure:**
```dart
testWidgets('description', (WidgetTester tester) async {
  // Build widget
  await tester.pumpWidget(MyWidget());

  // Find elements
  final button = find.byType(ElevatedButton);

  // Interact
  await tester.tap(button);
  await tester.pump();

  // Verify
  expect(find.text('Expected'), findsOneWidget);
});
```

## CI/CD Integration

### GitHub Actions Workflow

File: `.github/workflows/release.yml`

**Triggers:**
- Manual workflow dispatch
- Version bump selection (patch/minor/major)

**Jobs:**
1. **Version Calculation**
   - Reads latest git tag
   - Increments version based on input
   - Outputs new version and tag

2. **Android Build**
   - Runs on: Ubuntu latest
   - Java: 17 (Zulu distribution)
   - Flutter: 3.27.0 (stable)
   - Builds: Release APK
   - Artifact: `badminton_score-{version}.apk`

3. **iOS Build**
   - Runs on: macOS latest
   - Flutter: 3.27.0 (stable)
   - Builds: Unsigned IPA
   - Artifact: `badminton_score-{version}-unsigned.ipa`

4. **Release Creation**
   - Creates git tag
   - Creates GitHub release
   - Uploads APK and IPA
   - Generates release notes

### Running CI/CD Locally

**Test Android Build:**
```bash
flutter build apk --release --shrink
```

**Test iOS Build (macOS only):**
```bash
flutter build ios --release --no-codesign
```

**Verify Version:**
```bash
grep "^version:" pubspec.yaml
```

### Release Process

1. **Prepare Release**
   - Ensure all tests pass
   - Update version in pubspec.yaml (optional, CI updates it)
   - Commit and push changes

2. **Trigger Release**
   - Go to GitHub Actions
   - Run "Build and Release" workflow
   - Select version bump type (patch/minor/major)

3. **Verify Release**
   - Check GitHub Releases page
   - Download and test APK
   - Verify version number

4. **Distribute**
   - Share APK link with users
   - Upload to Google Play Store (if configured)
   - Submit to App Store (requires signing)

## Development Best Practices

### Performance

**Do:**
- Use `const` constructors where possible
- Preload assets in `initState()`
- Cache expensive computations
- Use `FittedBox` for responsive text
- Dispose resources in `dispose()`

**Don't:**
- Perform expensive operations in `build()`
- Create new objects in `build()` unnecessarily
- Forget to dispose controllers and players
- Use large images without optimization

### State Management

**Do:**
- Keep state minimal and focused
- Use `setState()` for simple state
- Scope `setState()` narrowly
- Validate state changes

**Don't:**
- Over-engineer with complex state management
- Store derived values in state
- Mutate state outside `setState()`
- Forget to update dependent state

### Code Organization

**Do:**
- Group related code together
- Use private methods for UI builders
- Keep methods focused and small
- Add comments for complex logic

**Don't:**
- Create unnecessary abstractions
- Split code prematurely
- Add unused parameters
- Over-comment obvious code

### Error Handling

**Do:**
- Handle async errors gracefully
- Provide user-friendly error messages
- Log errors for debugging
- Continue operation when possible

**Don't:**
- Crash on non-critical errors
- Expose technical errors to users
- Ignore errors silently
- Use errors for control flow

## Resources

### Official Documentation

- **Flutter:** https://flutter.dev/docs
- **Dart:** https://dart.dev/guides
- **Material Design:** https://material.io/design

### Package Documentation

- **audioplayers:** https://pub.dev/packages/audioplayers
- **wakelock_plus:** https://pub.dev/packages/wakelock_plus
- **shared_preferences:** https://pub.dev/packages/shared_preferences

### Tools

- **Flutter DevTools:** https://flutter.dev/docs/development/tools/devtools
- **Dart Analyzer:** https://dart.dev/tools/dartanalyzer
- **Flutter Doctor:** `flutter doctor -v`

### Community

- **Flutter Discord:** https://discord.gg/flutter
- **Stack Overflow:** Tag `flutter`
- **GitHub Issues:** Project repository

## Getting Help

### Debugging Steps

1. **Check Flutter Doctor**
   ```bash
   flutter doctor -v
   ```

2. **Clean Build**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Check Logs**
   ```bash
   flutter run -v
   ```

4. **Search Issues**
   - Check project GitHub issues
   - Search Stack Overflow
   - Check Flutter GitHub issues

5. **Ask for Help**
   - Provide error message
   - Include Flutter doctor output
   - Share relevant code
   - Describe steps to reproduce

### Reporting Bugs

Include:
- Flutter version (`flutter --version`)
- Device/emulator details
- Steps to reproduce
- Expected vs actual behavior
- Error messages and stack traces
- Screenshots if applicable

### Contributing

1. Fork repository
2. Create feature branch
3. Make changes
4. Add tests
5. Run linter and tests
6. Submit pull request

Follow commit conventions:
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring
- `docs:` - Documentation
- `test:` - Tests
- `style:` - Formatting

## Quick Reference

### Essential Commands

```bash
# Setup
flutter pub get                              # Install dependencies
dart run flutter_launcher_icons              # Generate icons
flutter pub run flutter_native_splash:create # Generate splash

# Development
flutter run                                  # Run debug
flutter run --release                        # Run release
flutter install --release                    # Install release

# Code Quality
dart format .                                # Format code
flutter analyze                              # Static analysis
flutter test                                 # Run tests

# Building
flutter build apk --release --shrink         # Android APK
flutter build appbundle --release            # Android bundle
flutter build ios --release --no-codesign    # iOS unsigned

# Debugging
flutter doctor                               # Check setup
flutter clean                                # Clean build
flutter devices                              # List devices
```

### File Locations

- **Main code:** `lib/main.dart`
- **Tests:** `test/widget_test.dart`
- **Assets:** `assets/`
- **Config:** `pubspec.yaml`
- **Linter:** `analysis_options.yaml`
- **Android:** `android/app/build.gradle.kts`
- **iOS:** `ios/Runner/Info.plist`

### Key Concepts

- **Hot Reload:** Press `r` while running
- **Hot Restart:** Press `R` while running
- **DevTools:** Press `w` while running
- **Quit:** Press `q` while running

### Support

- **Documentation:** README.md, CLAUDE.md
- **Issues:** GitHub repository
- **Community:** Flutter Discord, Stack Overflow
