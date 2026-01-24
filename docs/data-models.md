# Data Models Documentation

**Part:** main (Mobile Application - Flutter)
**Last Updated:** 2026-01-24
**Project Type:** Mobile Application (Flutter)

---

## Overview

This document describes the data models used in the Badminton Score Keeper application. The app uses an immutable state pattern with local state management via `setState()`. The codebase was recently modularized from a single-file architecture to a structured modular layout.

---

## Core Data Models

### GameState

**File:** `lib/models/game_state.dart`

The immutable state object representing the current game state.

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

  const GameState({
    required this.leftScore,
    required this.rightScore,
    required this.leftGames,
    required this.rightGames,
    required this.isLeftServing,
    required this.targetScore,
    required this.leftPlayerName,
    required this.rightPlayerName,
  });

  int get totalPoints => leftScore + rightScore;

  factory GameState.initial() {
    return const GameState(
      leftScore: 0,
      rightScore: 0,
      leftGames: 0,
      rightGames: 0,
      isLeftServing: true,
      targetScore: AppConstants.defaultTargetScore,
      leftPlayerName: 'Left',
      rightPlayerName: 'Right',
    );
  }

  GameState copyWith({
    int? leftScore,
    int? rightScore,
    int? leftGames,
    int? rightGames,
    bool? isLeftServing,
    int? targetScore,
    String? leftPlayerName,
    String? rightPlayerName,
  }) {
    return GameState(
      leftScore: leftScore ?? this.leftScore,
      rightScore: rightScore ?? this.rightScore,
      leftGames: leftGames ?? this.leftGames,
      rightGames: rightGames ?? this.rightGames,
      isLeftServing: isLeftServing ?? this.isLeftServing,
      targetScore: targetScore ?? this.targetScore,
      leftPlayerName: leftPlayerName ?? this.leftPlayerName,
      rightPlayerName: rightPlayerName ?? this.rightPlayerName,
    );
  }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `leftScore` | int | Current score for left player |
| `rightScore` | int | Current score for right player |
| `leftGames` | int | Games won by left player |
| `rightGames` | int | Games won by right player |
| `isLeftServing` | bool | True if left player is serving |
| `targetScore` | int | Winning score threshold |
| `leftPlayerName` | String | Custom name for left player |
| `rightPlayerName` | String | Custom name for right player |

---

### ScoreAction

**File:** `lib/models/score_action.dart`

Records a score change for undo functionality.

```dart
class ScoreAction {
  final bool isLeft;
  final int previousScore;
  final int newScore;
  final bool previousServerWasLeft;

  const ScoreAction({
    required this.isLeft,
    required this.previousScore,
    required this.newScore,
    required this.previousServerWasLeft,
  });
}
```

**Purpose:** Enables the undo feature by storing the state before each score change.

---

### MatchResult

**File:** `lib/models/match_result.dart`

Persisted match result for history tracking with JSON serialization.

```dart
class MatchResult {
  final DateTime date;
  final int leftScore;
  final int rightScore;
  final String leftPlayerName;
  final String rightPlayerName;
  final String winner;

  const MatchResult({
    required this.date,
    required this.leftScore,
    required this.rightScore,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.winner,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'leftScore': leftScore,
      'rightScore': rightScore,
      'leftPlayerName': leftPlayerName,
      'rightPlayerName': rightPlayerName,
      'winner': winner,
    };
  }

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      date: DateTime.parse(json['date'] as String),
      leftScore: json['leftScore'] as int,
      rightScore: json['rightScore'] as int,
      leftPlayerName: json['leftPlayerName'] as String,
      rightPlayerName: json['rightPlayerName'] as String,
      winner: json['winner'] as String,
    );
  }

  static String encodeList(List<MatchResult> results) {
    return jsonEncode(results.map((r) => r.toJson()).toList());
  }

  static List<MatchResult> decodeList(String json) {
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((item) => MatchResult.fromJson(item)).toList();
  }
}
```

**Persistence:** Stored in SharedPreferences as JSON-encoded list (max 50 matches).

---

### AppConstants

**File:** `lib/models/app_constants.dart`

Configuration constants for game rules and UI.

```dart
class AppConstants {
  // Layout Constants
  static const int scoreSectionFlex = 75;
  static const int controlSectionFlex = 25;
  static const double scoreTextSize = 256;
  static const double controlTextSize = 50;
  static const double buttonTextSize = 30;
  static const EdgeInsets gridPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

  // Badminton Rules
  static const int minTargetScore = 5;
  static const int defaultTargetScore = 21;
  static const int defaultMatchGames = 3; // Best of 3
  static const int maxScoreOffset = 9; // maxScore = targetScore + 9
  static const int minWinMargin = 2;
  static const List<int> targetScoreOptions = [11, 15, 21, 30];

  // Undo history limit
  static const int maxUndoHistory = 10;

  // Gesture thresholds
  static const double minSwipeVelocity = 500;

  // UI thresholds
  static const int highScoreThreshold = 10;
  static const double controlButtonHeight = 56;
}
```

---

## Theme System

### ThemeColors

**File:** `lib/theme/app_colors.dart`

Immutable color palette for theming.

```dart
class ThemeColors {
  final String name;
  final Color background;
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color accent;
  final Color glassBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color gamePoint;
  final Gradient backgroundGradient;

  const ThemeColors({
    required this.name,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.accent,
    required this.gamePoint,
    this.glassBorder = const Color(0x33FFFFFF),
    this.textPrimary = const Color(0xFFFFFFFF),
    this.textSecondary = const Color(0xB3FFFFFF),
    this.backgroundGradient = const LinearGradient(
      colors: [Color(0xFF1a1a1a), Color(0xFF121212)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  });
}
```

### AppThemes

**File:** `lib/theme/app_theme.dart`

Predefined theme configurations.

```dart
class AppThemes {
  static const Map<String, ThemeColors> themes = {
    'light': ThemeColors(...),
    'minimal': ThemeColors(...),
    'energy': ThemeColors(...),
    'court': ThemeColors(...),
    'champion': ThemeColors(...),
    'midnight': ThemeColors(...),
  };

  static final List<String> themeKeys = themes.keys.toList();
}
```

**Available Themes:**
| Key | Name | Description |
|-----|------|-------------|
| `light` | Light | Orange/amber on light gray |
| `minimal` | Minimal | Grayscale on white |
| `energy` | Energy | Red/orange on cream |
| `court` | Court | Green/lime on light green |
| `champion` | Champion | Pink/red on light pink |
| `midnight` | Midnight | Purple/teal on dark (default) |

---

## State Management Architecture

### Local State Pattern

The app uses `setState()` for local state management:

1. **Global State (Theme):** Managed in `BadmintonScoreApp` widget
2. **Game State:** Managed in `_ScoreScreenState` widget

### State Flow

```
User Input → _ScoreScreenState.setState() → UI Rebuild
                                              ↓
                                    SharedPreferences (persisted)
```

### Persistence

**Persisted to SharedPreferences:**
- Theme selection
- Sound toggle state
- Target score
- Player names
- Match history (JSON-encoded list, max 50)

**Transient (session-only):**
- Current scores
- Games won
- Undo history

---

## Validation Rules

### Win Detection

```dart
bool _checkWin(int score, int opponentScore) {
  final dynamicMaxScore = targetScore + AppConstants.maxScoreOffset;
  if (score >= dynamicMaxScore) return true;  // Sudden death cap
  if (score >= targetScore &&
      score - opponentScore >= AppConstants.minWinMargin) {
    return true;  // Normal win with margin
  }
  return false;
}
```

**Win Conditions:**
1. Score >= targetScore + 9 (sudden death cap at 30)
2. Score >= targetScore AND margin >= 2 points

### Score Validation
- Scores cannot go below 0 (checked in `_decrementScore`)
- Win detection triggered after each score increment

### Target Score Validation
- Minimum: 5 points
- Options: 11, 15, 21, 30

---

## Data Flow

### Score Increment Flow

```
1. User taps score area
2. _incrementScore(isLeft)
3. Create ScoreAction for undo history
4. setState() updates score and serving state
5. Check for win condition
6. Play audio feedback
7. Update UI
```

### Undo Flow

```
1. User taps Undo button
2. _undo() retrieves last ScoreAction from history
3. Restore previous score values
4. Restore serving state
5. setState() updates UI
```

---

## Memory Management

### Undo History Limits
- Maximum 10 actions stored (AppConstants.maxUndoHistory)
- Oldest action removed when limit exceeded
- Cleared on game reset or new game

### Match History Limits
- Maximum 50 matches stored
- Oldest match removed when limit exceeded

### Audio Resource Management
- Single `AudioPlayer` instance per screen
- Preloaded audio source in `initState()`
- Properly disposed in `dispose()`

### SharedPreferences Caching
- Single instance cached per state object
- Reduces async overhead on repeated access

---

## Module Structure

```
lib/
├── models/
│   ├── app_constants.dart    # Configuration constants
│   ├── game_state.dart       # Immutable game state
│   ├── score_action.dart     # Undo action record
│   └── match_result.dart     # Match result with JSON serialization
├── theme/
│   ├── theme.dart            # Re-exports
│   ├── app_colors.dart       # ThemeColors class
│   └── app_theme.dart        # AppThemes with 6 predefined themes
└── main.dart                 # App entry point and main UI
```

---

## Summary

| Model | Purpose | Persistence | File |
|-------|---------|-------------|------|
| `GameState` | Current game state | Transient | `game_state.dart` |
| `ScoreAction` | Undo history | Transient | `score_action.dart` |
| `MatchResult` | Match records | SharedPreferences | `match_result.dart` |
| `AppConstants` | Configuration | Static | `app_constants.dart` |
| `ThemeColors` | Theme palette | Static | `app_colors.dart` |
| `AppThemes` | Theme definitions | Static | `app_theme.dart` |

---

*Generated by BMAD document-project workflow (exhaustive scan)*
*Updated 2026-01-24 to reflect modularized architecture*
