# Architecture Documentation

**Part:** main (Mobile Application - Flutter)
**Last Updated:** 2026-01-24
**Project Type:** Mobile Application (Flutter)

---

## Executive Summary

The Badminton Score Keeper is a Flutter mobile application built with a **modularized architecture** optimized for simplicity, performance, and maintainability. The app provides a professional score tracking experience for local badminton communities with features including customizable themes, audio feedback, persistent storage, and advanced gesture controls.

**Key Characteristics:**
- **Architecture Pattern:** Modularized widget-based architecture
- **State Management:** Local setState() with SharedPreferences persistence
- **UI Framework:** Flutter Material Design 3 with glassmorphic design
- **Platform Support:** Android, iOS (primary), Web, Desktop (scaffolded)
- **Code Size:** ~1,250+ lines across 13 files
- **Dependencies:** 3 runtime packages (minimal footprint)

## Technology Stack

### Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | >=3.6.0 | Cross-platform mobile framework |
| **Dart** | >=3.6.0 | Programming language |
| **Material Design** | 3 | UI design system |

### Runtime Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **audioplayers** | ^6.4.0 | Audio playback for score feedback |
| **wakelock_plus** | ^1.2.5 | Keep screen awake during matches |
| **shared_preferences** | ^2.3.3 | Local data persistence |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **flutter_lints** | ^5.0.0 | Code quality and linting |
| **flutter_launcher_icons** | 0.14.3 | App icon generation |
| **flutter_native_splash** | ^2.3.7 | Splash screen generation |

### Platform Configuration

**Android:**
- Min SDK: API 21 (Android 5.0)
- Target SDK: Latest stable
- Java Version: 11
- Kotlin: Enabled
- Package: com.example.badminton_score

**iOS:**
- Deployment Target: iOS 12.0+
- Language: Swift
- Bundle ID: com.example.badmintonScore

## Architecture Pattern

### Modularized Widget-Based Architecture

**Pattern:** Application code is organized into three main modules: models, theme, and widgets, with a clean entry point in main.dart.

**Rationale:**
- **Organization:** Clear separation of concerns
- **Testability:** Each module can be tested independently
- **Maintainability:** Easy to locate and modify code
- **Team-Friendly:** Supports parallel development

**Module Structure:**
```
lib/
├── main.dart (~650 lines)      # Entry point and main screen
├── models/ (~150 lines)
│   ├── app_constants.dart      # Configuration constants
│   ├── game_state.dart         # Immutable state
│   ├── score_action.dart       # Undo history
│   └── match_result.dart       # Persistence model
├── theme/ (~155 lines)
│   ├── theme.dart              # Re-exports
│   ├── app_colors.dart         # ThemeColors class
│   └── app_theme.dart          # 6 theme definitions
└── widgets/ (~950 lines)
    ├── score_card.dart         # Score display
    ├── control_button.dart     # Control buttons
    ├── glass_container.dart    # Glassmorphic wrapper
    ├── win_dialog.dart         # Win celebration
    ├── settings_dialog.dart    # Settings modal
    ├── rename_dialog.dart      # Player names
    └── match_history_dialog.dart # Match history
```

**Benefits:**
- Clear separation of data, presentation, and logic
- Reusable components across the app
- Easy to add new features
- Improved code navigation

### Component Hierarchy

```
MaterialApp
└── BadmintonScoreApp (StatefulWidget)
    └── ScoreScreen (StatefulWidget)
        ├── SafeArea
        └── Column
            ├── Score Section (75% height)
            │   ├── Games Counter Row
            │   │   ├── Left Player Info
            │   │   ├── Serving Indicator
            │   │   └── Right Player Info
            │   └── Score Buttons Row
            │       ├── Left Score Button
            │       └── Right Score Button
            └── Control Section (25% height)
                └── Control Buttons Row
                    ├── Left Minus Button
                    ├── Undo Button
                    ├── Menu Button
                    ├── Swap Button
                    └── Right Minus Button
```

## State Management Architecture

### Two-Tier State Management

**Tier 1: Global State (Theme)**
- **Location:** `_BadmintonScoreAppState`
- **Scope:** Application-wide
- **Persistence:** SharedPreferences
- **Propagation:** Constructor parameters + callbacks

```dart
// Global state holder
class _BadmintonScoreAppState extends State<BadmintonScoreApp> {
  String currentTheme = ThemeKeys.defaultTheme;

  // Passed down to children
  ScoreScreen(
    currentTheme: currentTheme,
    onThemeChange: changeTheme,
  )
}
```

**Tier 2: Local State (Game State)**
- **Location:** `_ScoreScreenState`
- **Scope:** Screen-level
- **Persistence:** SharedPreferences (selective)
- **Update Pattern:** setState()

```dart
// Local state variables
int leftScore = 0;
int rightScore = 0;
int leftGames = 0;
int rightGames = 0;
bool soundEnabled = true;
bool isLeftServing = true;
int targetScore = 21;
String leftPlayerName = 'Left';
String rightPlayerName = 'Right';
List<ScoreAction> _undoHistory = [];
```

### State Flow Diagram

```
User Interaction
    ↓
Event Handler (_incrementScore, _swapSides, etc.)
    ↓
setState() - Update local state
    ↓
Widget Rebuild (build method)
    ↓
UI Update (Material widgets)
    ↓
[Optional] Persist to SharedPreferences
```

### State Persistence Strategy

**Persisted Data:**
- Theme preference (global)
- Sound toggle (local)
- Target score (local)
- Player names (local)

**Transient Data:**
- Current scores (reset on app restart)
- Games won (reset on app restart)
- Undo history (reset on app restart)
- Serving indicator (reset on app restart)

**Rationale:** Scores are session-specific; settings persist across sessions.

## Data Architecture

### Data Models

**1. GameState (Immutable)**
```dart
class GameState {
  final int leftScore;
  final int rightScore;
  final int leftGames;
  final int rightGames;
  final bool isLeftServing;
  final int targetScore;
  final String leftPlayerName;
  final String rightPlayerName;

  int get totalPoints => leftScore + rightScore;

  GameState copyWith({...}) { ... }
  factory GameState.initial() { ... }
}
```

**Purpose:** Represents complete game state at any point in time.

**2. ScoreAction (Immutable)**
```dart
class ScoreAction {
  final bool isLeft;
  final int previousScore;
  final int newScore;
  final bool previousServerWasLeft;
}
```

**Purpose:** Tracks individual score changes for undo functionality.

**3. ThemeColors (Immutable)**
```dart
class ThemeColors {
  final String name;
  final Color background;
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color accent;
  final Color gamePoint;
}
```

**Purpose:** Defines complete theme color palette.

### Data Flow

**Score Increment Flow:**
```
User taps score button
    ↓
_incrementScore(isLeft)
    ↓
setState(() {
  - Update score
  - Update totalPoints
  - Update serving indicator
  - Add to undo history
})
    ↓
_beep() - Play audio
    ↓
_checkWin() - Check win condition
    ↓
[If win] _showWinCelebration()
```

**Theme Change Flow:**
```
User swipes score area
    ↓
onPanEnd() - Detect swipe velocity
    ↓
_nextTheme() or _previousTheme()
    ↓
widget.onThemeChange(themeName)
    ↓
Parent setState() - Update currentTheme
    ↓
Save to SharedPreferences
    ↓
Widget rebuild with new theme
```

## UI Architecture

### Layout System

**Flex-Based Layout:**
- Score Section: 75% height (flex: 75)
- Control Section: 25% height (flex: 25)

**Responsive Design:**
- FittedBox for all text (prevents overflow)
- Expanded widgets for equal distribution
- SafeArea for platform insets
- Landscape-only orientation

### Component Design Pattern

**Builder Method Pattern:**
```dart
Widget _buildScoreButton({
  required int score,
  required VoidCallback onTap,
  required Color color,
  required Color textColor,
  // ... more parameters
}) {
  return Material(
    elevation: 8,
    child: InkWell(
      onTap: onTap,
      child: Container(
        // ... styling
        child: FittedBox(
          child: Text("$score"),
        ),
      ),
    ),
  );
}
```

**Benefits:**
- Reusable components
- Consistent styling
- Parameter-driven customization
- Clear separation of concerns

### Theme System Architecture

**Theme Definition:**
```dart
static const Map<String, ThemeColors> themes = {
  'light': ThemeColors(...),
  'minimal': ThemeColors(...),
  'energy': ThemeColors(...),
  'court': ThemeColors(...),
  'champion': ThemeColors(...),
};
```

**Theme Application:**
```dart
final theme = AppThemes.themes[widget.currentTheme]
    ?? AppThemes.themes[ThemeKeys.defaultTheme]!;

// Use theme colors
Container(color: theme.background)
Text(style: TextStyle(color: theme.onSurface))
```

**Theme Navigation:**
- Horizontal swipe gestures (velocity > 500 px/s)
- Menu selection
- Persisted to SharedPreferences

## Business Logic Architecture

### Game Rules Engine

**Win Detection Algorithm:**
```dart
bool _checkWin(int score, int opponentScore) {
  final dynamicMaxScore = targetScore + AppConstants.maxScoreOffset;

  // Sudden death cap
  if (score >= dynamicMaxScore) return true;

  // Standard win with margin
  if (score >= targetScore &&
      score - opponentScore >= AppConstants.minWinMargin) {
    return true;
  }

  return false;
}
```

**Rules:**
- Win at targetScore (default: 21) with 2-point margin
- Sudden death at targetScore + 9 (no margin required)
- Configurable target score (minimum: 5)

**Game Point Detection:**
```dart
bool _isGamePoint(int score, int opponentScore) {
  return _checkWin(score + 1, opponentScore);
}
```

**Serving Rules:**
```dart
void _updateServingIndicator(bool scoringTeamIsLeft) {
  // Team that scores serves next (standard badminton)
  isLeftServing = scoringTeamIsLeft;
}
```

### Undo System

**Implementation:**
```dart
List<ScoreAction> _undoHistory = [];

// On score increment
_undoHistory.add(ScoreAction(
  isLeft: isLeft,
  previousScore: previousScore,
  newScore: newScore,
  previousServerWasLeft: previousServerWasLeft,
));

// Limit history size
if (_undoHistory.length > AppConstants.maxUndoHistory) {
  _undoHistory.removeAt(0);
}

// On undo
void _undo() {
  if (_undoHistory.isEmpty) return;
  final lastAction = _undoHistory.removeLast();
  setState(() {
    // Restore previous state
  });
}
```

**Constraints:**
- Maximum 10 actions stored
- Only tracks increments (not decrements)
- Cleared on game reset

## Audio Architecture

### Audio System Design

**Single Player Pattern:**
```dart
late AudioPlayer _player;
late final Source _beepSource;

@override
void initState() {
  super.initState();
  _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  _beepSource = AssetSource('beep.mp3');
  _preloadAudio();
}

Future<void> _preloadAudio() async {
  await _player.setSource(_beepSource);
}
```

**Playback Strategy:**
```dart
Future<void> _beep() async {
  if (soundEnabled) {
    await _player.stop();  // Stop any playing audio
    await _player.play(_beepSource);
  }
}
```

**Benefits:**
- Preloading reduces latency (<50ms)
- Single instance prevents memory leaks
- Stop-before-play prevents overlap
- User-controllable toggle

## Animation Architecture

### Scale Animation System

**Controller Setup:**
```dart
late AnimationController _scaleController;
late Animation<double> _scaleAnimation;

_scaleController = AnimationController(
  duration: const Duration(milliseconds: 100),
  vsync: this,
);

_scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
  CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
);
```

**Application:**
```dart
AnimatedBuilder(
  animation: _scaleAnimation,
  builder: (context, child) {
    final scale = isScaling ? _scaleAnimation.value : 1.0;
    return Transform.scale(scale: scale, child: child);
  },
)
```

**Trigger:**
```dart
Future<void> _animateScoreButton(bool isLeft) async {
  setState(() { _isLeftScaling = true; });
  await _scaleController.forward();
  await _scaleController.reverse();
  setState(() { _isLeftScaling = false; });
}
```

## Gesture Architecture

### Multi-Gesture System

**Score Area Gestures:**
```dart
GestureDetector(
  onPanEnd: (details) {
    final velocity = details.velocity.pixelsPerSecond;
    final isHorizontalSwipe = velocity.dx.abs() > velocity.dy.abs();
    final isFastSwipe = velocity.dx.abs() > AppConstants.minSwipeVelocity;

    if (isHorizontalSwipe && isFastSwipe) {
      if (velocity.dx > 0) _previousTheme();
      else _nextTheme();
    }
  },
  child: // Score section
)
```

**Menu Button Dual Gesture:**
```dart
GestureDetector(
  onTap: () => _showMenuDialog(),
  onLongPress: () => _quickReset(),
  child: // Menu button
)
```

**Design Principles:**
- Velocity threshold prevents accidental triggers
- Directional detection for intuitive navigation
- Haptic feedback confirms actions

## Persistence Architecture

### SharedPreferences Strategy

**Cached Instance Pattern:**
```dart
SharedPreferences? _prefs;

Future<SharedPreferences> _getPrefs() async {
  _prefs ??= await SharedPreferences.getInstance();
  return _prefs!;
}
```

**Benefits:**
- Reduces async overhead
- Single instance per state object
- Automatic cleanup by Flutter

**Persistence Points:**
- Theme changes: Immediate save
- Sound toggle: Save on change
- Game settings: Save on dialog confirm
- Player names: Save on dialog confirm

## Platform Integration Architecture

### Platform Channels

**Current Status:** No custom platform channels used.

**Standard Integration:**
- SystemChrome for orientation lock
- SystemUiMode for immersive mode
- WakelockPlus for screen wake lock
- HapticFeedback for vibration

### Platform-Specific Code

**Android:**
- MainActivity.kt: Standard Flutter activity (no customization)
- AndroidManifest.xml: Permissions and configuration
- build.gradle.kts: Build configuration

**iOS:**
- AppDelegate.swift: Standard Flutter app delegate (no customization)
- Info.plist: App configuration and permissions
- Xcode project: Build settings

## Performance Architecture

### Optimization Strategies

**1. Const Constructors**
```dart
static const Map<String, ThemeColors> themes = { ... };
static const EdgeInsets gridPadding = EdgeInsets.symmetric(...);
```

**2. Cached Values**
```dart
static final List<String> themeKeys = themes.keys.toList();
```

**3. Asset Preloading**
```dart
Future<void> _preloadAudio() async {
  await _player.setSource(_beepSource);
}
```

**4. Narrow setState Scope**
```dart
setState(() {
  leftScore++;  // Only update what changed
});
```

**5. FittedBox for Text**
```dart
FittedBox(
  fit: BoxFit.scaleDown,
  child: Text("$score"),
)
```

### Memory Management

**Resource Disposal:**
```dart
@override
void dispose() {
  _player.dispose();
  _scaleController.dispose();
  super.dispose();
}
```

**Undo History Limits:**
```dart
if (_undoHistory.length > AppConstants.maxUndoHistory) {
  _undoHistory.removeAt(0);
}
```

## Security Architecture

### Security Considerations

**Data Security:**
- No sensitive data stored
- Local-only storage (SharedPreferences)
- No network communication
- No user authentication required

**Input Validation:**
- Target score: Minimum 5 points
- Player names: Trimmed, default fallback
- Score values: Cannot go below 0

**Platform Security:**
- Standard Flutter security model
- No custom permissions required
- No external data access

## Accessibility Architecture

### Accessibility Features

**Semantics Labels:**
```dart
Semantics(
  label: 'Score: $score. Tap to increment',
  button: true,
  child: // Score button
)
```

**Visual Accessibility:**
- High contrast themes (WCAG AA compliant)
- Large touch targets (score buttons: 75% screen height)
- Clear visual hierarchy
- Consistent font family (Poppins)

**Haptic Feedback:**
- Light impact: Theme changes, undo
- Medium impact: Reset, swap sides
- Heavy impact: Win celebration

## Testing Architecture

### Test Strategy

**Widget Tests:**
- Location: test/widget_test.dart
- Framework: Flutter's built-in testing
- Coverage: Widget rendering, win detection, game state

**Test Structure:**
```dart
testWidgets('description', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  final button = find.byType(ElevatedButton);
  await tester.tap(button);
  await tester.pump();
  expect(find.text('Expected'), findsOneWidget);
});
```

**Test Coverage:**
- Win condition validation
- Score increment/decrement
- Game state management
- UI rendering

## Deployment Architecture

### Build Configuration

**Android Release:**
```bash
flutter build apk --release --shrink
```

**Output:** ~19 MB APK

**Optimizations:**
- Shrinking enabled
- Unused code removed
- ProGuard/R8 obfuscation

**iOS Release:**
```bash
flutter build ios --release --no-codesign
```

**Requirements:**
- Apple Developer account
- Code signing certificate
- Provisioning profile

### CI/CD Architecture

**GitHub Actions Pipeline:**
1. Version calculation (semantic versioning)
2. Android build (Ubuntu runner, Java 17, Flutter 3.27.0)
3. iOS build (macOS runner, Flutter 3.27.0)
4. Release creation with artifacts

**Artifacts:**
- Android: badminton_score-{version}.apk
- iOS: badminton_score-{version}-unsigned.ipa

## Architecture Decisions

### Key Design Decisions

**1. Single-File Architecture**
- **Decision:** Keep all code in one file
- **Rationale:** Simplicity, fast development, easy navigation
- **Trade-off:** Large file size, limited parallel development
- **Threshold:** Split at 2,000+ lines

**2. No State Management Library**
- **Decision:** Use setState() instead of Provider/Riverpod
- **Rationale:** Simple state requirements, no complex data flows
- **Trade-off:** Manual state propagation
- **Threshold:** Add library if state becomes complex

**3. Minimal Dependencies**
- **Decision:** Only 3 runtime dependencies
- **Rationale:** Reduce app size, minimize maintenance
- **Trade-off:** Some features require custom implementation
- **Benefit:** 19 MB APK size

**4. Offline-First Design**
- **Decision:** No network communication
- **Rationale:** Local community use, reliability
- **Trade-off:** No cloud sync, no analytics
- **Benefit:** Works anywhere, no privacy concerns

**5. Landscape-Only Orientation**
- **Decision:** Lock to landscape mode
- **Rationale:** Natural holding position, better layout
- **Trade-off:** Not usable in portrait
- **Benefit:** Optimized UI layout

## Architecture Evolution

### Current State (v1.0.0)

**Characteristics:**
- Single-file architecture
- Local state management
- Offline-only operation
- 5 themes
- Basic undo (10 actions)

### Future Considerations

**When to Split Files:**
- File exceeds 2,000 lines
- Multiple developers working simultaneously
- Need for code reuse across projects

**Suggested Split:**
```
lib/
├── main.dart
├── constants.dart
├── models/
│   ├── game_state.dart
│   ├── score_action.dart
│   └── theme_colors.dart
├── theme/
│   └── app_themes.dart
└── screens/
    └── score_screen.dart
```

**When to Add State Management:**
- Complex data flows emerge
- Multiple screens added
- Shared state across features

**Potential Features:**
- Match history tracking
- Statistics and analytics
- Multiple game modes
- Online multiplayer
- Cloud sync

## Architecture Metrics

### Code Metrics

| Metric | Value |
|--------|-------|
| Total Lines | 1,580 |
| Classes | 7 |
| Methods | 25+ |
| Dependencies | 3 runtime |
| Test Coverage | Widget tests |

### Performance Metrics

| Metric | Value |
|--------|-------|
| APK Size | ~19 MB |
| Audio Latency | <50ms |
| Hot Reload | <1s |
| Build Time | ~30s |

### Quality Metrics

| Metric | Status |
|--------|--------|
| Linting | Passing |
| Tests | Passing |
| WCAG AA | Compliant |
| Security | No vulnerabilities |

## Architecture Diagrams

### System Context

```
┌─────────────────────────────────────┐
│   Badminton Score Keeper App       │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Flutter Framework          │  │
│  │   - Material Design          │  │
│  │   - Platform Channels        │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Local Storage              │  │
│  │   - SharedPreferences        │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Audio System               │  │
│  │   - AudioPlayer              │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
         │                    │
         ▼                    ▼
    ┌─────────┐          ┌─────────┐
    │ Android │          │   iOS   │
    │ Device  │          │ Device  │
    └─────────┘          └─────────┘
```

### Component Architecture

```
┌────────────────────────────────────────┐
│         BadmintonScoreApp              │
│  (Global State: Theme)                 │
└────────────────┬───────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────┐
│           ScoreScreen                  │
│  (Local State: Scores, Settings)       │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │  Score Section (75%)             │ │
│  │  - Games Counter                 │ │
│  │  - Score Buttons                 │ │
│  │  - Gesture Detection             │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │  Control Section (25%)           │ │
│  │  - Minus Buttons                 │ │
│  │  - Undo Button                   │ │
│  │  - Menu Button                   │ │
│  │  - Swap Button                   │ │
│  └──────────────────────────────────┘ │
└────────────────────────────────────────┘
```

## Conclusion

The Badminton Score Keeper demonstrates a **pragmatic architecture** that prioritizes simplicity, performance, and maintainability over complex abstractions. The single-file approach, minimal dependencies, and offline-first design make it an ideal solution for local community use.

**Architecture Strengths:**
- ✅ Simple and easy to understand
- ✅ Fast development and iteration
- ✅ Excellent performance (19 MB APK)
- ✅ Reliable offline operation
- ✅ Accessible and user-friendly

**Architecture Limitations:**
- ⚠️ Large single file (1,580 lines)
- ⚠️ Limited scalability for complex features
- ⚠️ Manual state management

**Recommended for:**
- Small to medium mobile apps
- Offline-first applications
- Community-focused tools
- Rapid prototyping

**Not recommended for:**
- Large-scale applications
- Complex data flows
- Multi-developer teams
- Cloud-integrated services

The architecture successfully balances simplicity with functionality, delivering a polished user experience while maintaining clean, maintainable code.
