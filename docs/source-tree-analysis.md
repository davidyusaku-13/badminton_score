# Source Tree Analysis

## Project Structure Overview

```
badminton_score/
├── lib/                          # Dart source code (single-file architecture)
│   └── main.dart                 # Complete application (1580 lines)
├── test/                         # Test files
│   └── widget_test.dart          # Widget tests
├── assets/                       # Application assets
│   ├── fonts/                    # Poppins font family (20 variants)
│   ├── beep.mp3                  # Score increment sound (45 KB)
│   ├── beep-original.mp3         # Original beep backup (3.1 KB)
│   └── splash.png                # App icon source (100 KB)
├── android/                      # Android platform code
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── kotlin/       # MainActivity.kt
│   │   │   │   ├── res/          # Android resources (icons, drawables)
│   │   │   │   └── AndroidManifest.xml
│   │   │   ├── debug/            # Debug configuration
│   │   │   └── profile/          # Profile configuration
│   │   └── build.gradle.kts      # Android build configuration
│   └── gradle/                   # Gradle wrapper
├── ios/                          # iOS platform code
│   ├── Runner/
│   │   ├── Assets.xcassets/      # iOS app icons and launch images
│   │   ├── Base.lproj/           # iOS storyboards
│   │   ├── Info.plist            # iOS app configuration
│   │   └── AppDelegate.swift     # iOS app delegate
│   └── Runner.xcodeproj/         # Xcode project
├── linux/                        # Linux platform code
│   └── flutter/                  # Flutter Linux embedder
├── macos/                        # macOS platform code
│   └── Runner/                   # macOS app bundle
├── web/                          # Web platform code
│   ├── index.html                # Web entry point
│   └── manifest.json             # Web app manifest
├── windows/                      # Windows platform code
│   └── runner/                   # Windows app runner
├── build/                        # Build artifacts (generated)
├── docs/                         # Generated documentation
│   ├── project-scan-report.json  # Workflow state
│   ├── data-models.md            # Data model documentation
│   ├── ui-components.md          # UI component inventory
│   └── asset-inventory.md        # Asset catalog
├── _bmad/                        # BMAD workflow system
│   ├── bmm/                      # BMM module
│   └── core/                     # Core workflow engine
├── _bmad-output/                 # BMAD output directory
├── .github/                      # GitHub configuration
│   ├── workflows/
│   │   └── release.yml           # CI/CD release pipeline
│   └── copilot-instructions.md   # GitHub Copilot instructions
├── .dart_tool/                   # Dart tooling cache (generated)
├── .idea/                        # IntelliJ IDEA configuration
├── pubspec.yaml                  # Flutter project configuration
├── pubspec.lock                  # Dependency lock file
├── analysis_options.yaml         # Dart analyzer configuration
├── README.md                     # User documentation
├── CLAUDE.md                     # Claude Code instructions
└── .gitignore                    # Git ignore rules
```

## Critical Directories

### 1. lib/ - Application Source Code

**Purpose:** Contains all Dart application code

**Structure:**
```
lib/
└── main.dart (1580 lines)
    ├── Constants (lines 8-32)
    │   ├── AppConstants - UI dimensions and game rules
    │   └── ThemeKeys - Theme identifier constants
    ├── Data Models (lines 43-196)
    │   ├── ThemeColors - Theme color palette
    │   ├── ScoreAction - Undo history entry
    │   └── GameState - Complete game state
    ├── Theme System (lines 65-121)
    │   └── AppThemes - 5 theme definitions
    ├── Main Entry Point (lines 198-209)
    │   └── main() - App initialization
    ├── Root Widget (lines 211-288)
    │   └── BadmintonScoreApp - Theme state holder
    └── Main Screen (lines 290-1579)
        └── ScoreScreen - Complete UI implementation
            ├── State Management (lines 306-400)
            ├── Audio System (lines 402-426)
            ├── Game Logic (lines 428-703)
            ├── Theme Navigation (lines 705-718)
            ├── UI Builders (lines 741-1180)
            └── Dialogs (lines 788-1454)
```

**Key Files:**
- `main.dart` - **Entry point** and complete application

**Architecture Pattern:**
- Single-file architecture with clear class separation
- No subdirectories (intentional simplicity)
- All code in one file for easy navigation and maintenance

**Code Organization:**
1. **Constants** (top of file) - Configuration values
2. **Data Models** - Immutable state classes
3. **Theme System** - Color definitions
4. **Main Function** - App initialization
5. **Root Widget** - Global state (theme)
6. **Main Screen** - Local state (scores, UI)

### 2. test/ - Test Suite

**Purpose:** Widget and unit tests

**Structure:**
```
test/
└── widget_test.dart
    ├── Widget tests for BadmintonScoreApp
    ├── Win detection logic tests
    └── Game state tests
```

**Test Coverage:**
- Widget rendering tests
- Win condition validation
- Game state management
- Score increment/decrement logic

**Test Framework:** Flutter's built-in testing framework

### 3. assets/ - Application Assets

**Purpose:** Static resources bundled with the app

**Structure:**
```
assets/
├── fonts/                    # Typography assets
│   ├── Poppins-Regular.ttf   # Used (400 weight)
│   ├── Poppins-SemiBold.ttf  # Used (600 weight)
│   └── [18 unused variants]  # Can be removed
├── beep.mp3                  # Production audio (45 KB)
├── beep-original.mp3         # Backup (3.1 KB, unused)
└── splash.png                # App icon source (100 KB)
```

**Asset Usage:**
- **Active:** 2 fonts, 1 audio, 1 image = ~500 KB
- **Unused:** 18 fonts, 1 audio = ~2.8 MB (optimization opportunity)

**Asset Declaration:** `pubspec.yaml:36-48`

### 4. android/ - Android Platform

**Purpose:** Android-specific code and configuration

**Structure:**
```
android/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── kotlin/com/example/badminton_score/
│   │   │   │   └── MainActivity.kt          # Android entry point
│   │   │   ├── res/                         # Android resources
│   │   │   │   ├── drawable-*/              # Splash screen assets
│   │   │   │   ├── mipmap-*/                # App icons (5 densities)
│   │   │   │   ├── values/                  # Styles and colors
│   │   │   │   └── values-night/            # Dark theme values
│   │   │   └── AndroidManifest.xml          # App permissions and config
│   │   ├── debug/
│   │   │   └── AndroidManifest.xml          # Debug configuration
│   │   └── profile/
│   │       └── AndroidManifest.xml          # Profile configuration
│   └── build.gradle.kts                     # Build configuration
├── gradle/                                  # Gradle wrapper
└── settings.gradle                          # Gradle settings
```

**Key Configuration:**
- **Package:** `com.example.badminton_score`
- **Min SDK:** Defined by Flutter (typically API 21)
- **Target SDK:** Defined by Flutter (latest stable)
- **Compile SDK:** Defined by Flutter
- **Java Version:** 11 (build.gradle.kts:14-20)
- **Kotlin:** Enabled (build.gradle.kts:3)

**Generated Assets:**
- App icons in 5 densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Splash screen drawables for different API levels

### 5. ios/ - iOS Platform

**Purpose:** iOS-specific code and configuration

**Structure:**
```
ios/
├── Runner/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/              # App icons (multiple sizes)
│   │   ├── LaunchBackground.imageset/       # Splash background
│   │   └── LaunchImage.imageset/            # Splash image
│   ├── Base.lproj/
│   │   ├── LaunchScreen.storyboard          # Launch screen UI
│   │   └── Main.storyboard                  # Main storyboard
│   ├── Info.plist                           # iOS app configuration
│   ├── AppDelegate.swift                    # iOS app delegate
│   └── Runner-Bridging-Header.h             # Objective-C bridge
├── Runner.xcodeproj/                        # Xcode project
└── Flutter/                                 # Flutter iOS embedder
```

**Key Configuration:**
- **Bundle ID:** `com.example.badmintonScore`
- **Deployment Target:** iOS 12.0+ (typical Flutter default)
- **Language:** Swift
- **Orientation:** Landscape only (configured in Info.plist)

**Generated Assets:**
- App icons in multiple sizes (20pt to 1024pt)
- Launch screen assets

### 6. linux/, macos/, windows/, web/ - Other Platforms

**Purpose:** Platform-specific code for desktop and web

**Status:**
- Scaffolded by Flutter (default structure)
- Not actively configured for this project
- Can be used for deployment if needed

**Structure:**
- Each contains platform-specific entry points
- Flutter embedder code
- Platform-specific build configurations

### 7. .github/ - GitHub Configuration

**Purpose:** GitHub-specific configuration and automation

**Structure:**
```
.github/
├── workflows/
│   └── release.yml                          # CI/CD pipeline
└── copilot-instructions.md                  # GitHub Copilot guidance
```

**CI/CD Pipeline (release.yml):**
- **Trigger:** Manual workflow dispatch
- **Jobs:**
  1. Version calculation (semantic versioning)
  2. Android APK build (Ubuntu runner)
  3. iOS unsigned build (macOS runner)
  4. GitHub release creation with artifacts

**Copilot Instructions:**
- Architecture overview
- Key patterns and conventions
- Essential workflows
- Implementation details

### 8. docs/ - Generated Documentation

**Purpose:** Project documentation generated by BMAD workflow

**Structure:**
```
docs/
├── project-scan-report.json                 # Workflow state tracking
├── data-models.md                           # Data model documentation
├── ui-components.md                         # UI component inventory
└── asset-inventory.md                       # Asset catalog
```

**Status:** Currently being generated (Step 5 of 12)

### 9. _bmad/ - BMAD Workflow System

**Purpose:** BMAD (Build, Manage, Automate, Deploy) workflow engine

**Structure:**
```
_bmad/
├── bmm/                                     # BMM module
│   ├── config.yaml                          # Project configuration
│   ├── workflows/                           # Workflow definitions
│   └── data/                                # Workflow data files
└── core/                                    # Core workflow engine
    ├── tasks/                               # Task definitions
    └── workflows/                           # Core workflows
```

**Purpose:** Provides structured workflows for project documentation and development

## Entry Points

### Application Entry Point

**File:** `lib/main.dart:198-209`

**Function:** `main()`

**Initialization Sequence:**
1. `WidgetsFlutterBinding.ensureInitialized()` - Initialize Flutter framework
2. `SystemChrome.setPreferredOrientations()` - Lock to landscape
3. `SystemChrome.setEnabledSystemUIMode()` - Enable immersive mode
4. `WakelockPlus.enable()` - Keep screen awake
5. `runApp(BadmintonScoreApp())` - Launch app

**Code:**
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    runApp(const BadmintonScoreApp());
  });
}
```

### Android Entry Point

**File:** `android/app/src/main/kotlin/com/example/badminton_score/MainActivity.kt`

**Class:** `MainActivity`

**Purpose:** Standard Flutter Android activity (no custom code)

### iOS Entry Point

**File:** `ios/Runner/AppDelegate.swift`

**Class:** `AppDelegate`

**Purpose:** Standard Flutter iOS app delegate (no custom code)

## Build Artifacts (Generated)

### build/ Directory

**Purpose:** Contains compiled code and build outputs

**Structure:**
```
build/
├── app/                                     # Android build outputs
│   ├── intermediates/                       # Intermediate build files
│   └── outputs/
│       └── flutter-apk/
│           └── app-release.apk              # Release APK (~19 MB)
├── ios/                                     # iOS build outputs
│   └── iphoneos/
│       └── Runner.app                       # iOS app bundle
└── web/                                     # Web build outputs
```

**Note:** This directory is in `.gitignore` and regenerated on each build

### .dart_tool/ Directory

**Purpose:** Dart tooling cache and metadata

**Contents:**
- Package configuration
- Analysis cache
- Build metadata

**Note:** Generated by Dart/Flutter tools, not committed to git

## Configuration Files

### pubspec.yaml

**Location:** Root directory

**Purpose:** Flutter project configuration and dependencies

**Key Sections:**
- **name:** `badminton_score`
- **version:** `1.0.0+1`
- **environment:** Dart SDK >=3.6.0
- **dependencies:** 3 runtime dependencies
- **dev_dependencies:** 3 development tools
- **flutter:** Asset and font declarations

### analysis_options.yaml

**Location:** Root directory

**Purpose:** Dart analyzer configuration

**Configuration:**
- Base rules from `package:flutter_lints/flutter.yaml`
- Custom rule overrides for project preferences
- Linting rules for code quality

### .gitignore

**Location:** Root directory

**Purpose:** Git ignore patterns

**Ignored:**
- Build artifacts (`build/`, `.dart_tool/`)
- IDE files (`.idea/`, `.vscode/`)
- Platform-specific generated files
- Dependency caches

## Integration Points

### Platform Integration

**Android:**
- Entry: `MainActivity.kt`
- Manifest: `AndroidManifest.xml`
- Build: `build.gradle.kts`

**iOS:**
- Entry: `AppDelegate.swift`
- Config: `Info.plist`
- Build: Xcode project

**Communication:** Flutter platform channels (none used in this app)

### External Services

**None:** This app is completely offline with no external API calls

### Local Storage

**SharedPreferences:**
- Theme preference
- Sound toggle
- Target score
- Player names

**Location:** Platform-specific (Android: SharedPreferences, iOS: UserDefaults)

## Development Workflow

### Local Development

1. **Setup:**
   ```bash
   flutter pub get                    # Install dependencies
   ```

2. **Run:**
   ```bash
   flutter run                        # Debug mode
   flutter run --release              # Release mode
   ```

3. **Test:**
   ```bash
   flutter test                       # Run tests
   flutter analyze                    # Static analysis
   ```

### Asset Generation

1. **App Icons:**
   ```bash
   dart run flutter_launcher_icons
   ```

2. **Splash Screen:**
   ```bash
   flutter pub run flutter_native_splash:create
   ```

### Build Process

1. **Android APK:**
   ```bash
   flutter build apk --release --shrink
   ```

2. **iOS App:**
   ```bash
   flutter build ios --release
   ```

3. **Install to Device:**
   ```bash
   flutter install --release
   ```

## Architecture Highlights

### Single-File Architecture

**Rationale:**
- Simple project with clear boundaries
- Easy navigation (no file jumping)
- Fast development iteration
- Clear code organization within file

**Trade-offs:**
- Large file size (1580 lines)
- All code in one namespace
- Limited parallel development

**When to Split:**
- File exceeds 2000 lines
- Multiple developers working simultaneously
- Need for code reuse across projects

### No State Management Library

**Rationale:**
- Simple state requirements
- Local state sufficient for UI
- Global state only for theme
- No complex data flows

**Current Approach:**
- `setState()` for local state
- Constructor callbacks for parent communication
- `SharedPreferences` for persistence

### Platform-Specific Code

**Current Status:** Minimal platform-specific code

**Android:**
- Standard MainActivity (no customization)
- Manifest permissions (none required)

**iOS:**
- Standard AppDelegate (no customization)
- Info.plist configuration (orientation lock)

**Future Considerations:**
- Native splash screen customization
- Platform-specific theming
- Native share functionality

## Directory Size Analysis

| Directory | Purpose | Approximate Size | Committed to Git |
|-----------|---------|------------------|------------------|
| lib/ | Source code | ~50 KB | Yes |
| test/ | Tests | ~10 KB | Yes |
| assets/ | Assets | 3.1 MB | Yes |
| android/ | Android platform | ~100 KB | Yes |
| ios/ | iOS platform | ~50 KB | Yes |
| linux/ | Linux platform | ~30 KB | Yes |
| macos/ | macOS platform | ~30 KB | Yes |
| windows/ | Windows platform | ~30 KB | Yes |
| web/ | Web platform | ~10 KB | Yes |
| docs/ | Documentation | ~100 KB | Yes |
| _bmad/ | Workflow system | ~500 KB | Yes |
| build/ | Build artifacts | ~200 MB | No (gitignored) |
| .dart_tool/ | Dart cache | ~50 MB | No (gitignored) |

**Total Repository Size:** ~4 MB (excluding build artifacts)

## Navigation Guide

### Finding Specific Code

**Constants and Configuration:**
- UI dimensions: `lib/main.dart:8-32`
- Game rules: `lib/main.dart:18-24`
- Theme definitions: `lib/main.dart:65-121`

**Data Models:**
- GameState: `lib/main.dart:139-196`
- ScoreAction: `lib/main.dart:124-136`
- ThemeColors: `lib/main.dart:43-63`

**Core Functionality:**
- Score increment: `lib/main.dart:573-606`
- Win detection: `lib/main.dart:438-453`
- Theme switching: `lib/main.dart:705-718`
- Undo logic: `lib/main.dart:623-638`

**UI Components:**
- Score button: `lib/main.dart:1465-1535`
- Control button: `lib/main.dart:1537-1578`
- Menu dialog: `lib/main.dart:1182-1276`

**Platform Code:**
- Android entry: `android/app/src/main/kotlin/.../MainActivity.kt`
- iOS entry: `ios/Runner/AppDelegate.swift`
- Android manifest: `android/app/src/main/AndroidManifest.xml`
- iOS config: `ios/Runner/Info.plist`

### Common Tasks

**Adding a New Theme:**
1. Add theme key to `ThemeKeys` (optional)
2. Add theme definition to `AppThemes.themes` (line 66)
3. Define all 8 colors (background, primary, secondary, surface, onSurface, accent, gamePoint)

**Modifying UI Layout:**
1. Update `AppConstants` for dimensions (lines 8-32)
2. Modify builder methods in `_ScoreScreenState` (lines 741-1180)

**Adding Persistence:**
1. Add field to `_ScoreScreenState`
2. Load in `_loadPreferences()` (lines 366-386)
3. Save in `_savePreferences()` (lines 388-400)

**Modifying Game Rules:**
1. Update `AppConstants` (lines 18-24)
2. Update win detection logic (lines 438-453)
3. Update tests in `test/widget_test.dart`

## Optimization Opportunities

### Asset Optimization

**High Priority:**
- Remove 18 unused font files (~2.8 MB savings)
- Remove beep-original.mp3 (~3 KB savings)

**Medium Priority:**
- Compress splash.png (~20-30 KB savings)
- Consider audio compression for beep.mp3

### Code Organization

**Current:** Single file (1580 lines)

**Future Consideration:** Split into modules if:
- File exceeds 2000 lines
- Multiple features added
- Team size increases

**Suggested Split:**
```
lib/
├── main.dart                    # Entry point
├── constants.dart               # AppConstants, ThemeKeys
├── models/
│   ├── game_state.dart          # GameState
│   ├── score_action.dart        # ScoreAction
│   └── theme_colors.dart        # ThemeColors
├── theme/
│   └── app_themes.dart          # Theme definitions
└── screens/
    └── score_screen.dart        # Main UI
```

### Build Optimization

**Current:** Release APK ~19 MB (with shrinking)

**Optimization Applied:**
- `--shrink` flag enabled
- Unused font variants not declared in pubspec.yaml

**Future:**
- Enable ProGuard/R8 obfuscation
- Split APKs by ABI
- App bundle for Play Store

## Summary

The badminton score keeper follows a **single-file architecture** optimized for simplicity and maintainability. The project structure is clean with clear separation between:

- **Source code** (lib/) - Single Dart file
- **Platform code** (android/, ios/, etc.) - Minimal customization
- **Assets** (assets/) - Fonts, audio, images
- **Configuration** (pubspec.yaml, analysis_options.yaml)
- **Documentation** (docs/, README.md, CLAUDE.md)

The architecture prioritizes:
- **Simplicity** - No complex abstractions
- **Performance** - Minimal dependencies, optimized assets
- **Maintainability** - Clear code organization, comprehensive documentation
- **Offline-first** - No external dependencies or API calls
