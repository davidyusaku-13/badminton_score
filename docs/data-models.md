# Data Models

## Overview

The badminton score keeper uses a minimal data model architecture with three primary classes for managing application state and configuration.

## Core Data Models

### 1. GameState

**Location:** `lib/main.dart:139-196`

**Purpose:** Immutable data class representing the complete game state at any point in time.

**Fields:**
- `leftScore: int` - Current score for left player
- `rightScore: int` - Current score for right player
- `leftGames: int` - Games won by left player
- `rightGames: int` - Games won by right player
- `isLeftServing: bool` - Serving indicator (true = left serves)
- `targetScore: int` - Configurable win target (default: 21)
- `leftPlayerName: String` - Left player display name
- `rightPlayerName: String` - Right player display name

**Computed Properties:**
- `totalPoints: int` - Sum of both scores (leftScore + rightScore)

**Methods:**
- `copyWith()` - Creates modified copy with selective field updates
- `GameState.initial()` - Factory constructor for default initial state

**Usage Pattern:**
```dart
// Immutable state updates via copyWith
final newState = currentState.copyWith(leftScore: 5);
```

### 2. ScoreAction

**Location:** `lib/main.dart:124-136`

**Purpose:** Represents a single score change action for undo functionality.

**Fields:**
- `isLeft: bool` - Which side scored (true = left, false = right)
- `previousScore: int` - Score before the action
- `newScore: int` - Score after the action
- `previousServerWasLeft: bool` - Serving state before action

**Usage Pattern:**
```dart
// Stored in undo history list (max 10 entries)
_undoHistory.add(ScoreAction(
  isLeft: true,
  previousScore: 4,
  newScore: 5,
  previousServerWasLeft: true,
));
```

**Constraints:**
- Maximum history size: 10 actions (defined in `AppConstants.maxUndoHistory`)
- Only tracks score increments, not manual decrements

### 3. ThemeColors

**Location:** `lib/main.dart:43-63`

**Purpose:** Immutable data class defining a complete theme color palette.

**Fields:**
- `name: String` - Display name of theme
- `background: Color` - Main background color
- `primary: Color` - Primary button/accent color (left score)
- `secondary: Color` - Secondary button color (right score)
- `surface: Color` - Control button surface color
- `onSurface: Color` - Text color on surfaces
- `accent: Color` - Menu button and serving indicator color
- `gamePoint: Color` - Special color for game point state

**Theme Definitions:**
- **Light** - Orange/amber on light gray background
- **Minimal** - Grayscale on white background
- **Energy** - Red/orange on cream background
- **Court** - Green/lime on light green background
- **Champion** - Pink/red on light pink background

**Usage Pattern:**
```dart
// Themes stored in const Map for compile-time optimization
static const Map<String, ThemeColors> themes = {
  'light': ThemeColors(name: 'Light', background: Color(0xFFFAFAFA), ...),
  // ... other themes
};
```

## Configuration Constants

### AppConstants

**Location:** `lib/main.dart:8-32`

**Purpose:** Centralized configuration for UI dimensions and game rules.

**UI Constants:**
- `scoreSectionFlex: 75` - Score area height percentage
- `controlSectionFlex: 25` - Control area height percentage
- `scoreTextSize: 256` - Base font size for scores
- `controlTextSize: 50` - Font size for control buttons
- `buttonTextSize: 30` - Font size for menu items
- `controlButtonHeight: 56` - Fixed height for control buttons

**Game Rules:**
- `minTargetScore: 5` - Minimum allowed target score
- `defaultTargetScore: 21` - Standard badminton target
- `maxScoreOffset: 9` - Sudden death cap (target + 9)
- `minWinMargin: 2` - Required lead to win at target

**Behavioral Constants:**
- `maxUndoHistory: 10` - Maximum undo actions stored
- `minSwipeVelocity: 500` - Pixels/second for theme swipe
- `highScoreThreshold: 10` - Score threshold for reset undo option

## Data Persistence

### SharedPreferences Storage

**Persisted Data:**
- `theme: String` - Current theme key
- `soundEnabled: bool` - Audio feedback toggle
- `targetScore: int` - Custom target score setting
- `leftPlayerName: String` - Left player name
- `rightPlayerName: String` - Right player name

**Storage Pattern:**
```dart
// Cached instance to avoid repeated async calls
SharedPreferences? _prefs;

Future<SharedPreferences> _getPrefs() async {
  _prefs ??= await SharedPreferences.getInstance();
  return _prefs!;
}
```

**Persistence Locations:**
- Theme changes: Immediate save on theme switch
- Sound toggle: Saved when changed in menu
- Game settings: Saved when dialog confirmed
- Player names: Saved when dialog confirmed

## State Management Architecture

### Local State (setState)

**Managed in:** `_ScoreScreenState` class

**State Variables:**
- Score tracking: `leftScore`, `rightScore`, `leftGames`, `rightGames`
- Game configuration: `targetScore`, `leftPlayerName`, `rightPlayerName`
- UI state: `soundEnabled`, `isLeftServing`, `totalPoints`
- Animation state: `_isLeftScaling`, `_isRightScaling`
- History: `_undoHistory` (List<ScoreAction>)

**Update Pattern:**
```dart
void _incrementScore(bool isLeft) {
  setState(() {
    if (isLeft) leftScore++;
    else rightScore++;
    totalPoints++;
    _updateServingIndicator(isLeft);
    _undoHistory.add(ScoreAction(...));
  });
  _beep();
  // Check for win condition
}
```

### Global State (Theme)

**Managed in:** `_BadmintonScoreAppState` class

**State Variables:**
- `currentTheme: String` - Active theme key
- `_isLoading: bool` - Initial load state

**Propagation:**
- Theme passed down via constructor: `ScoreScreen(currentTheme: currentTheme)`
- Changes propagated up via callback: `onThemeChange: changeTheme`

## Data Flow Diagram

```
User Action
    ↓
Event Handler (_incrementScore, _swapSides, etc.)
    ↓
setState() - Update local state
    ↓
Widget Rebuild (build method)
    ↓
UI Update (Material widgets)
    ↓
Optional: Persist to SharedPreferences
```

## Validation Rules

### Score Validation
- Scores cannot go below 0 (checked in `_decrementScore`)
- Win detection at `targetScore` with 2-point margin
- Sudden death at `targetScore + 9` (no margin required)

### Target Score Validation
- Minimum: 5 points (`AppConstants.minTargetScore`)
- No maximum enforced
- Validated in game settings dialog before saving

### Player Name Validation
- Empty names default to "Left" / "Right"
- No length restrictions
- Trimmed before saving

## Memory Management

### Undo History Limits
- Maximum 10 actions stored
- Oldest action removed when limit exceeded
- Cleared on game reset or new game

### Audio Resource Management
- Single `AudioPlayer` instance
- Preloaded audio source in `initState()`
- Properly disposed in `dispose()` method

### SharedPreferences Caching
- Single instance cached per state object
- Reduces async overhead on repeated access
- No manual cleanup required (managed by Flutter)
