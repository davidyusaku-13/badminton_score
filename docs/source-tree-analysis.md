# Source Tree Analysis

**Part:** main (Mobile Application - Flutter)
**Last Updated:** 2026-01-24
**Project Type:** Mobile Application (Flutter)

---

## Project Structure Overview

```
badminton_score/
├── lib/                          # Dart source code (modularized)
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── app_constants.dart    # Configuration constants
│   │   ├── game_state.dart       # Immutable game state
│   │   ├── score_action.dart     # Undo action record
│   │   └── match_result.dart     # Match result with JSON
│   ├── theme/                    # Theme system
│   │   ├── theme.dart            # Re-exports
│   │   ├── app_colors.dart       # ThemeColors class
│   │   └── app_theme.dart        # AppThemes definitions
│   └── widgets/                  # UI components
│       ├── score_card.dart       # Player score display
│       ├── control_button.dart   # Action buttons
│       ├── glass_container.dart  # Glassmorphic wrapper
│       ├── win_dialog.dart       # Win celebration
│       ├── settings_dialog.dart  # Game settings
│       ├── rename_dialog.dart    # Player names
│       └── match_history_dialog.dart  # Match history
├── test/                         # Test files
│   └── widget_test.dart          # Widget tests
├── assets/                       # Application assets
│   ├── fonts/                    # Poppins font family
│   ├── beep.mp3                  # Score increment sound
│   ├── beep-original.mp3         # Backup audio
│   └── splash.png                # App icon source
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── docs/                         # Generated documentation
├── _bmad/                        # BMAD workflow system
├── _bmad-output/                 # BMAD output directory
├── .github/                      # GitHub configuration
├── pubspec.yaml                  # Flutter project configuration
├── analysis_options.yaml         # Dart analyzer configuration
├── README.md                     # User documentation
└── CLAUDE.md                     # Claude Code instructions
```

---

## Critical Directories

### 1. lib/ - Application Source Code

**Purpose:** Contains all Dart application code with modular structure

**Structure:**
```
lib/
├── main.dart                     # App entry point (~650 lines)
├── models/
│   ├── app_constants.dart        # Configuration (~30 lines)
│   ├── game_state.dart           # Game state model (~60 lines)
│   ├── score_action.dart         # Undo action (~15 lines)
│   └── match_result.dart         # Match persistence (~50 lines)
├── theme/
│   ├── theme.dart                # Re-exports (~5 lines)
│   ├── app_colors.dart           # Theme colors (~35 lines)
│   └── app_theme.dart            # Theme definitions (~115 lines)
└── widgets/
    ├── score_card.dart           # Score display (~110 lines)
    ├── control_button.dart       # Control buttons (~50 lines)
    ├── glass_container.dart      # Glass effect (~55 lines)
    ├── win_dialog.dart           # Win dialog (~140 lines)
    ├── settings_dialog.dart      # Settings modal (~120 lines)
    ├── rename_dialog.dart        # Player rename (~150 lines)
    └── match_history_dialog.dart # Match history (~200 lines)
```

**Total Lines:** ~1,250+ lines across 13 files

**Architecture Pattern:**
- Modularized architecture with clear separation
- Separate directories for models, theme, widgets
- Re-export module for theme system

**Code Organization:**
1. **models/** - Data classes and constants
2. **theme/** - Color definitions and theme presets
3. **widgets/** - Reusable UI components
4. **main.dart** - Entry point and main screen

### 2. test/ - Test Suite

**Purpose:** Widget and unit tests

**Structure:**
```
test/
└── widget_test.dart
    ├── AppConstants tests
    ├── GameState tests
    ├── Win detection logic tests
    ├── Theme system tests
    ├── ScoreAction tests
    └── Widget rendering tests
```

**Test Framework:** Flutter's built-in testing framework

### 3. assets/ - Application Assets

**Structure:**
```
assets/
├── fonts/
│   ├── Poppins-Regular.ttf       # Used (400 weight)
│   ├── Poppins-SemiBold.ttf      # Used (600 weight)
│   └── [18 unused variants]      # Can be removed
├── beep.mp3                      # Production audio (~45 KB)
├── beep-original.mp3             # Backup (~3 KB, unused)
└── splash.png                    # App icon source (~100 KB)
```

**Asset Usage:**
- **Active:** 2 fonts, 1 audio, 1 image = ~500 KB
- **Unused:** 18 fonts, 1 audio = ~2.8 MB

### 4. android/ - Android Platform

**Structure:**
```
android/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── kotlin/.../MainActivity.kt
│   │   │   ├── res/
│   │   │   └── AndroidManifest.xml
│   │   ├── debug/
│   │   └── profile/
│   └── build.gradle.kts
├── gradle/
└── settings.gradle
```

**Key Configuration:**
- **Package:** `com.example.badminton_score`
- **Min SDK:** API 21+
- **Java Version:** 11

### 5. ios/ - iOS Platform

**Structure:**
```
ios/
├── Runner/
│   ├── Assets.xcassets/
│   ├── Base.lproj/
│   ├── Info.plist
│   ├── AppDelegate.swift
│   └── Runner-Bridging-Header.h
└── Runner.xcodeproj/
```

**Key Configuration:**
- **Bundle ID:** `com.example.badmintonScore`
- **Deployment Target:** iOS 12.0+
- **Orientation:** Landscape only

### 6. .github/ - GitHub Configuration

**Structure:**
```
.github/
├── workflows/
│   └── release.yml               # CI/CD pipeline
└── copilot-instructions.md       # GitHub Copilot guidance
```

**CI/CD Pipeline:**
- Trigger: Manual workflow dispatch
- Jobs: Version, Android build, iOS build, Release

### 7. docs/ - Generated Documentation

**Structure:**
```
docs/
├── project-scan-report.json      # Workflow state
├── index.md                      # Master index
├── project-overview.md           # Project summary
├── architecture.md               # Architecture docs
├── source-tree-analysis.md       # This file
├── data-models.md                # Data model docs
├── ui-components.md              # Component inventory
└── asset-inventory.md            # Asset catalog
```

---

## Entry Points

### Application Entry Point

**File:** `lib/main.dart`

**Initialization:**
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

**File:** `android/app/src/main/kotlin/.../MainActivity.kt`
- Standard Flutter activity (no customization)

### iOS Entry Point

**File:** `ios/Runner/AppDelegate.swift`
- Standard Flutter app delegate (no customization)

---

## Module Structure Summary

| Directory | Contents | Purpose |
|-----------|----------|---------|
| `lib/models/` | 4 files | Data models and constants |
| `lib/theme/` | 3 files | Theme colors and definitions |
| `lib/widgets/` | 7 files | Reusable UI components |
| `lib/main.dart` | 1 file | Entry point and main screen |

**Total Source Files:** 13 Dart files

---

## Navigation Guide

### Finding Specific Code

**Data Models:**
- Constants: `lib/models/app_constants.dart`
- Game state: `lib/models/game_state.dart`
- Undo actions: `lib/models/score_action.dart`
- Match results: `lib/models/match_result.dart`

**Theme:**
- Color palette: `lib/theme/app_colors.dart`
- Theme definitions: `lib/theme/app_theme.dart`

**UI Components:**
- Score display: `lib/widgets/score_card.dart`
- Control buttons: `lib/widgets/control_button.dart`
- Glass container: `lib/widgets/glass_container.dart`
- Dialogs: `lib/widgets/*_dialog.dart`

### Common Tasks

**Adding a New Theme:**
1. Add colors to `lib/theme/app_colors.dart`
2. Add theme entry to `lib/theme/app_theme.dart`

**Adding a New Widget:**
1. Create file in `lib/widgets/`
2. Export from parent if needed

**Modifying Game Rules:**
1. Update `lib/models/app_constants.dart`
2. Update tests in `test/widget_test.dart`

---

## Architecture Evolution

| Version | Architecture | Date |
|---------|--------------|------|
| 1.0.0 | Single-file (~1580 lines) | 2026-01-16 |
| 1.1.0 | Modularized (13 files) | 2026-01-24 |

**Benefits of Modularization:**
- Better code organization
- Improved testability
- Easier maintenance
- Team-friendly development

---

*Generated by BMAD document-project workflow (exhaustive scan)*
*Updated 2026-01-24 to reflect modularized architecture*
