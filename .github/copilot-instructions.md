# Copilot Instructions: Badminton Score Keeper

A professional Flutter badminton score tracking app with customizable themes and advanced gesture controls. The entire app is contained in `lib/main.dart` with clear architectural layers.

## Architecture Overview

**Single-File Design**: All code lives in `lib/main.dart` (~566 lines) organized into logical class layers:

- **Constants Layer**: `AppConstants` (UI dimensions), `ThemeKeys` (theme identifiers)
- **Theme System**: `AppThemes` (theme definitions), `ThemeColors` (color data class)
- **Widget Tree**: `BadmintonScoreApp` (state holder) → `ScoreScreen` (main UI)

**Data Flow**: Theme state held at `BadmintonScoreApp` level, passed down to `ScoreScreen` via constructor callbacks. Score state (`leftScore`, `rightScore`, `soundEnabled`) managed locally in `_ScoreScreenState`.

## Key Patterns & Conventions

### Theme Management Pattern

- All 7 themes defined in `AppThemes.themes` Map with consistent color set: `primary`, `secondary`, `surface`, `onSurface`, `accent`, `background`
- Theme colors accessed via `AppThemes.themes[widget.currentTheme] ?? AppThemes.themes[ThemeKeys.defaultTheme]!`
- Add new themes by: (1) adding key to `ThemeKeys`, (2) creating `ThemeColors` entry in `AppThemes.themes`, (3) ensuring all 6 colors exist
- Theme switching via swipe gestures (horizontal velocity > 500 px/s) triggers `_nextTheme()` / `_previousTheme()` with haptic feedback

### Widget Building Convention

- Private methods follow `_build*` naming: `_buildScoreSection()`, `_buildMenuButton()`, `_buildScoreButton()`
- All buttons use `FittedBox(fit: BoxFit.scaleDown)` for responsive text scaling (prevents overflow on different devices)
- Color parameters consistent across builders: `color` (background), `textColor` (foreground)

### State Management

- Simple `setState()` pattern—no Provider/Riverpod needed
- Gesture callbacks update scores directly: `setState(() => leftScore++); _beep();`
- Theme changes trigger parent rebuild via `widget.onThemeChange(themeName)`
- Audio operations (`_beep()`, `_stopSound()`) check `soundEnabled` flag before playing

### Audio & Haptics

- `AudioPlayer` initialized in `initState()` with `ReleaseMode.stop` (cleanup on app pause)
- Beep plays **only** on score increments; stops on all other button presses (`_stopSound()`)
- Haptic feedback (`HapticFeedback.lightImpact()`) confirms theme switches; `mediumImpact()` on reset

## Essential Workflows

### Running the App

```bash
flutter pub get                                    # Install dependencies
flutter run                                        # Run on connected device
flutter install --release                         # Install optimized release
```

### Building for Distribution

```bash
flutter build apk --release --shrink              # ~19MB optimized APK
flutter build appbundle --release                 # Google Play Store bundle
dart run flutter_launcher_icons                   # Regenerate app icons
flutter pub run flutter_native_splash:create      # Regenerate splash screen
```

### Testing & Analysis

```bash
flutter test                                       # Run widget tests (see test/widget_test.dart)
flutter analyze                                    # Static analysis
dart format .                                      # Format code
```

## Critical Implementation Details

### Landscape Lock

- `SystemChrome.setPreferredOrientations()` in `main()` restricts to landscape only
- `SystemUiMode.immersiveSticky` hides status/nav bars for full-screen experience
- `WakelockPlus.enable()` prevents screen timeout during matches

### Layout Structure

- Score section 75% height (flex: 75), Control section 25% height (flex: 25)
- Score buttons use `FittedBox` with `scoreTextSize = 256` for responsive display
- Control buttons fixed 56px height with Material Design elevation on score buttons only

### Gesture Complexity

- Menu button has dual gesture: `onTap()` opens dialog, `onLongPress()` instant resets
- Score area gestures only trigger on horizontal swipes with velocity > 500 px/s (prevents accidental theme changes during tap)
- Swipe direction: velocity > 0 = previous theme, velocity < 0 = next theme

### Audio Asset Loading

- Beep sound loaded as `AssetSource('beep.mp3')` (declared in `pubspec.yaml` under `assets`)
- Player disposed in `dispose()` to prevent memory leaks
- All audio stops when menu opens or non-score buttons pressed (via `_stopSound()`)

## Dependencies (Minimal Set)

- **`audioplayers: ^6.4.0`** - Score feedback sound
- **`wakelock_plus: ^1.2.5`** - Screen always-on
- **`flutter_launcher_icons: 0.14.3`** - Icon generation (dev)
- **`flutter_native_splash: ^2.3.7`** - Splash screen (dev)

No state management, HTTP, or database libraries—optimized for offline local use.

## Common Modifications

### Adding a New Theme

1. Define colors: `ThemeKeys.myNewTheme = 'myNewTheme'` (optional, themes auto-enumerate)
2. Add to `AppThemes.themes`:
   ```dart
   'myNewTheme': ThemeColors(
     name: 'My Theme',
     background: Color(...), primary: Color(...), secondary: Color(...),
     surface: Color(...), onSurface: Color(...), accent: Color(...)
   ),
   ```
3. Test contrast ratios meet WCAG AA standards

### Adjusting UI Constants

- Update `AppConstants` class values
- `FittedBox` handles text scaling automatically—no manual adjustments needed
- Test on landscape devices after changes

### Modifying Gesture Behavior

- Swipe velocity threshold: increase `500` in `onPanEnd()` to require faster swipes
- Long-press reset: change `onLongPress()` callback in `_buildMenuButton()`
- Score button behavior: modify increment/decrement in `_buildScoreButton()` `onTap` callback

## Code Quality Notes

- **No null safety violations**: All widgets use `required` parameters, proper null coalescing
- **Accessible colors**: All themes tested for WCAG AA contrast compliance
- **Resource cleanup**: `AudioPlayer` disposed, `WakelockPlus` lifecycle managed
- **Efficient rebuilds**: `setState()` scoped narrowly to avoid unnecessary widget rebuilds

## Commit Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for all commits:

**Format**: `<type>(<scope>): <subject>`

**Types**:

- `feat`: New feature (e.g., `feat(theme): add ocean theme`)
- `fix`: Bug fix (e.g., `fix(gesture): prevent accidental theme swap on tap`)
- `refactor`: Code restructuring without feature changes (e.g., `refactor(audio): extract beep logic`)
- `style`: Formatting, whitespace (e.g., `style: format main.dart`)
- `docs`: Documentation updates (e.g., `docs: update README`)
- `test`: Add or update tests (e.g., `test(gesture): add swipe velocity tests`)

**Examples**:

- `feat(theme): add dark mode theme with WCAG AA colors`
- `fix(score): prevent negative score values on decrement`
- `refactor(widget): extract ScoreButton into separate method`
- `docs(README): add installation instructions`

## Testing Entry Point

See `test/widget_test.dart` for widget testing pattern. Add tests for new gesture handlers, theme transitions, and audio state.
