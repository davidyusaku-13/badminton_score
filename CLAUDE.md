# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A professional Flutter badminton score keeper application designed for local community use. Features a clean Material Design interface with advanced gesture controls, multiple themes, and community-focused functionality. The app is optimized for landscape mobile devices with emphasis on simplicity and reliability.

## Architecture Summary

### Single-File Architecture (lib/main.dart)
The entire application (~1264 lines) is contained in one well-organized file with clear separation of concerns:

**Core Classes:**
- `AppConstants` - UI dimensions, font sizes, layout constants, badminton rules (minTargetScore, defaultTargetScore, maxScoreOffset, minWinMargin, maxUndoHistory)
- `ThemeKeys` - String constants for theme names with default
- `AppThemes` - Theme definitions with Material Design color schemes, cached `themeKeys` list
- `ThemeColors` - Const data class for theme configuration (8 colors including gamePoint)
- `ScoreAction` - Data class for undo history tracking
- `BadmintonScoreApp` - Root widget managing global theme state with persistence
- `ScoreScreen` - Main UI with modular widget architecture and animations

**Widget Architecture:**
- `_buildScoreSection()` - Top score display area (75% height) with swipe gestures
- `_buildControlSection()` - Bottom control buttons (25% height)
- `_buildMenuButton()` - Custom hamburger menu with tap/long-press handling
- `_buildScoreButton()` - Material Design score buttons with elevation
- `_buildControlButton()` - Outlined control buttons for minus actions
- `_buildGridItem()` - Consistent padding wrapper

**Data Flow:**
- Theme state held at `BadmintonScoreApp` level, persisted via `SharedPreferences`, passed to `ScoreScreen` via callbacks
- Score state (`leftScore`, `rightScore`, `leftGames`, `rightGames`, `soundEnabled`, `isLeftServing`, `totalPoints`, `targetScore`) managed locally in `_ScoreScreenState`
- Undo history tracked via `List<ScoreAction>` with max 10 entries (AppConstants.maxUndoHistory)
- Theme and game settings (soundEnabled, targetScore) persisted via `SharedPreferences`
- Theme changes trigger parent rebuild via `widget.onThemeChange(themeName)` and persist to storage

## Key Features Implementation

### Theme System
- **5 Themes**: Light, Minimal, Energy, Court, Champion
- **Theme Storage**: All themes defined as `const Map<String, ThemeColors>` with 8 consistent colors (background, primary, secondary, surface, onSurface, accent, gamePoint)
- **Cached Keys**: `AppThemes.themeKeys` cached list for performance (avoids allocations during swipes)
- **Swipe Navigation**: Horizontal swipes (velocity > 500 px/s) on score area cycle through themes
- **Persistence**: Theme choice saved to `SharedPreferences` and restored on app launch
- **Theme Preview**: Color swatches shown in theme selector dialog

### Game Tracking
- **Score Tracking**: Left and right scores with increment/decrement
- **Games Won**: Tracks games won per side across a match
- **Configurable Target Score**: Users can set custom target scores (minimum 5, default 21) via Game Settings dialog
- **Win Detection**: Automatic win detection at targetScore (2+ margin) or targetScore + 9 (sudden death cap)
- **Win Celebration**: Modal dialog with haptic feedback, shows final score and target, options to continue or start new game
- **Serving Indicator**: Visual indicator showing which side should serve (team that scores serves next - standard badminton rules)
- **Game Point Indicator**: Score buttons change to `gamePoint` color with glow effect when one point away from winning

### Advanced Controls
- **Tap Score Areas**: Increment with sound feedback and scale animation
- **Minus Buttons**: Decrement scores (silent)
- **Undo Button**: Reverts last score change (up to 10 actions tracked), disabled state when history is empty
- **Swap Sides Button**: Swaps scores, games, and serving indicator (for court changes)
- **Hamburger Menu**: Dual gesture - tap opens dialog, long press instant resets
- **Reset Score**: Menu option to reset current game scores (with confirmation dialog)
- **Reset Match**: Menu option to reset both scores and games won
- **Game Settings**: Menu option to configure target score with validation (min 5)
- **Sound Toggle**: Persisted to `SharedPreferences`
- **Quick Reset Undo**: Snackbar with undo option when resetting high scores (>10)

### User Experience Features
- **Screen Always On**: `WakelockPlus.enable()` in `main()` prevents screen timeout
- **Landscape Lock**: `SystemChrome.setPreferredOrientations()` restricts to landscape only
- **Immersive Mode**: `SystemUiMode.immersiveSticky` hides status/navigation bars for fullscreen
- **FittedBox Text**: All buttons use `FittedBox(fit: BoxFit.scaleDown)` for responsive text scaling
- **Audio Preloading**: `_player.setSource()` called during init to reduce first-play latency
- **Scale Animation**: Score buttons animate on tap via `AnimationController`
- **Accessibility**: `Semantics` labels on all interactive elements for screen readers
- **Haptic Feedback**: `lightImpact()` for themes/undo, `mediumImpact()` for resets/swaps, `heavyImpact()` for wins

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
- `shared_preferences: ^2.3.3` - Persist theme and sound settings

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

### Widget Building Conventions
- Private methods prefixed with `_build` for UI components
- All buttons use `FittedBox(fit: BoxFit.scaleDown)` to prevent text overflow on different screen sizes
- Consistent color parameter ordering: `color` (background), `textColor` (foreground)
- Descriptive parameter names with `required` annotations for null safety

### State Management Pattern
- Simple `setState()` pattern for score and theme state (no Provider/Riverpod needed)
- Theme state managed at app level with `SharedPreferences` persistence
- Audio, animation, and UI state managed locally in `ScoreScreen`
- Undo history via `List<ScoreAction>` with max 10 entries
- `_safeAction()` helper wraps actions that should stop audio first
- Narrow `setState()` scope to avoid unnecessary widget rebuilds

### Gesture Handling
- Score area gestures only trigger on horizontal swipes with velocity > 500 px/s
- Swipe direction: positive velocity = previous theme, negative velocity = next theme
- Menu button dual gesture: `onTap()` opens dialog, `onLongPress()` instant resets
- Score buttons: scale animation on tap using `AnimationController`

### Animation System
- `SingleTickerProviderStateMixin` for animation controller
- `_scaleController` with 100ms duration for score button feedback
- `Transform.scale()` applied conditionally based on `_isLeftScaling` / `_isRightScaling` flags

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
- Theme keys cached in `AppThemes.themeKeys` to avoid list allocations during swipes
- Audio preloaded during init to eliminate first-play latency

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
- `Semantics` labels on all buttons and indicators for screen reader support
- Disabled state styling for undo button when history is empty

### Local Use Optimization
- Fast theme switching for different court conditions
- Instant reset for quick game transitions
- Silent minus buttons to avoid audio conflicts
- Landscape orientation for natural holding position

## Future Maintenance Notes

### Adding New Themes
1. Add theme key to `ThemeKeys` class (optional - themes auto-enumerate from Map)
2. Define all 8 colors in `AppThemes.themes`:
   ```dart
   'myNewTheme': ThemeColors(
     name: 'My Theme',
     background: Color(...), primary: Color(...), secondary: Color(...),
     surface: Color(...), onSurface: Color(...), accent: Color(...),
     gamePoint: Color(...),
   ),
   ```
3. Test contrast ratios for WCAG AA accessibility compliance

### Modifying UI Constants
- Update `AppConstants` class values (scoreSectionFlex: 75, controlSectionFlex: 25, scoreTextSize: 256, etc.)
- Badminton rules: minTargetScore (5), defaultTargetScore (21), maxScoreOffset (9), minWinMargin (2)
- FittedBox will handle text scaling automatically
- Test on different screen sizes after changes

### Adjusting Gesture Behavior
- Swipe velocity threshold: Modify `500` in `onPanEnd()` to require faster/slower swipes
- Long-press reset: Change `onLongPress()` callback in `_buildMenuButton()`
- Score increment/decrement: Modify `onTap` callbacks in `_buildScoreButton()`

### Code Organization
- Keep single-file structure for simplicity
- Use private methods for UI components
- Maintain consistent parameter ordering
- Follow Material Design principles for new features

## Linting Configuration

Custom rules in `analysis_options.yaml`:
- `avoid_print: false` - Print statements allowed for debugging
- `prefer_const_constructors: false` - Not enforced to reduce boilerplate
- `prefer_const_constructors_in_immutables: false` - Not enforced for widget constructors
- `prefer_const_literals_to_create_immutables: false` - Not enforced to reduce boilerplate
- `prefer_final_fields: false` - Mutable fields allowed
- `unnecessary_breaks: true` - Enforces clean switch statements
- `use_key_in_widget_constructors: false` - Keys not required for all widgets
- Base rules from `package:flutter_lints/flutter.yaml`

## Commit Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/) format: `<type>(<scope>): <subject>`

**Types:**
- `feat` - New feature (e.g., `feat(theme): add ocean theme`)
- `fix` - Bug fix (e.g., `fix(gesture): prevent accidental theme swap on tap`)
- `refactor` - Code restructuring (e.g., `refactor(audio): extract beep logic`)
- `style` - Formatting (e.g., `style: format main.dart`)
- `docs` - Documentation (e.g., `docs: update README installation steps`)
- `test` - Tests (e.g., `test(gesture): add swipe velocity tests`)

## Testing

- Test file: `test/widget_test.dart`
- Run tests: `flutter test`
- Add tests for new gesture handlers, theme transitions, and audio state changes
- Widget testing pattern follows standard Flutter test conventions

This app represents a complete, polished solution for badminton community score tracking with professional-grade UI/UX and optimized performance.