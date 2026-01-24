# UI Component Inventory

**Part:** main (Mobile Application - Flutter)
**Last Updated:** 2026-01-24
**Project Type:** Mobile Application (Flutter)

---

## Overview

The Badminton Score Keeper uses a modularized widget-based architecture with glassmorphic design elements. All UI components are organized in the `lib/widgets/` directory with clear separation of concerns.

## Component Architecture

### Widget Hierarchy

```
BadmintonScoreApp (StatefulWidget)
└── MaterialApp
    └── ScoreScreen (StatefulWidget)
        └── Scaffold
            └── SafeArea
                └── Column
                    ├── Expanded (75% - Score Section)
                    │   └── Row
                    │       ├── ScoreCard [Left]
                    │       └── ScoreCard [Right]
                    └── Expanded (25% - Control Section)
                        └── Row
                            ├── ControlButton [Left -1]
                            ├── ControlButton [Undo]
                            ├── ControlButton [Menu]
                            ├── ControlButton [Swap]
                            └── ControlButton [Right -1]

Dialogs (overlay on top):
├── WinDialog
├── SettingsDialog
├── RenameDialog
└── MatchHistoryDialog
```

---

## Core Components

### ScoreCard

**File:** `lib/widgets/score_card.dart`

**Purpose:** Large interactive score display with tap-to-increment and swipe-to-decrement

```dart
class ScoreCard extends StatelessWidget {
  final int score;
  final String playerName;
  final bool isServing;
  final bool isWinner;
  final VoidCallback onTap;
  final VoidCallback onSwipeDown;
  final VoidCallback onNameTap;
  final ThemeColors theme;
}
```

**Features:**
- Tap to increment score
- Vertical swipe down to decrement
- Animated score changes with AnimatedSwitcher
- Game point highlighting with glow effect
- Serving indicator border
- Player name display with edit capability

**Visual Features:**
- GlassContainer with blur effect
- Border radius: 24px
- Score text: Poppins Bold, dynamic sizing
- Serving indicator: accent color border

---

### ControlButton

**File:** `lib/widgets/control_button.dart`

**Purpose:** Outlined action buttons for secondary controls

```dart
class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeColors theme;
}
```

**Features:**
- Icon + label combination
- GlassContainer styling
- Haptic feedback on tap

**Visual Features:**
- Border radius: 16px
- Icon size: 28px
- Label font: Poppins Medium, 12px

---

### GlassContainer

**File:** `lib/widgets/glass_container.dart`

**Purpose:** Reusable glassmorphic container with backdrop blur

```dart
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final Gradient? gradient;
}
```

**Features:**
- BackdropFilter with blur
- Configurable opacity and blur amount
- Optional gradient background
- Custom border and padding

---

## Dialog Components

### WinDialog

**File:** `lib/widgets/win_dialog.dart`

**Purpose:** Game won celebration modal

**Features:**
- Trophy icon (64px, amber)
- "Game Won!" announcement
- Winner name display
- Final score display
- "Continue Match" / "New Game" actions

---

### SettingsDialog

**File:** `lib/widgets/settings_dialog.dart`

**Purpose:** Game settings configuration

**Features:**
- Target score dropdown (11, 15, 21, 30)
- Sound effects toggle (Switch)
- Settings persisted to SharedPreferences

---

### RenameDialog

**File:** `lib/widgets/rename_dialog.dart`

**Purpose:** Player name input

**Features:**
- Two TextField inputs (left/right)
- TextEditingController management
- Validation: empty defaults to "Left"/"Right"
- Proper controller disposal

---

### MatchHistoryDialog

**File:** `lib/widgets/match_history_dialog.dart`

**Purpose:** Display past match results

**Features:**
- ListView of match results
- Reversed order (newest first)
- Winner badges with color coding
- Date formatting (Today/Yesterday/Date)
- Clear history option (with confirmation)
- Empty state: "No matches yet"

---

## Theme System Integration

### ThemeColors Usage

All components accept a `ThemeColors` theme parameter for consistent styling:

| Color Role | Usage |
|------------|-------|
| `background` | Screen background gradient |
| `primary` | Left score, primary actions |
| `secondary` | Right score, secondary actions |
| `surface` | Dialog surfaces, glass containers |
| `accent` | Menu button, serving indicator |
| `gamePoint` | Game point highlighting |
| `textPrimary` | Primary text color |
| `textSecondary` | Secondary text color |
| `glassBorder` | Glass container borders |

---

## Layout System

### Flex Distribution

| Section | Flex | Percentage |
|---------|------|------------|
| Score Section | 75 | 75% |
| Control Section | 25 | 25% |

### Responsive Design

- **FittedBox:** All text uses `BoxFit.scaleDown` to prevent overflow
- **SafeArea:** Respects system UI insets
- **Flexible:** Layout adapts to screen sizes

---

## Gesture Handling

### Score Area Gestures

| Gesture | Action |
|---------|--------|
| Tap | Increment score |
| Vertical Drag Down | Decrement score |

### Control Gestures

| Button | Gesture | Action |
|--------|---------|--------|
| Menu | Tap | Open menu dialog |
| Menu | Long Press | Reset scores |
| Undo | Tap | Revert last action |
| Swap | Tap | Swap sides |

---

## Animation System

### AnimatedSwitcher

Used in ScoreCard for smooth score transitions:
- Duration: 300ms
- Transition: Scale animation
- Key: Score value (triggers on change)

---

## Accessibility Features

### Semantics Labels

All interactive elements include:
- Descriptive labels for screen readers
- Button role indicators
- State information (enabled/disabled)

### Touch Targets

- Score cards: 75% of screen height
- Control buttons: 56px height minimum
- Adequate spacing between elements

---

## Component Summary

| Component | Type | File | Purpose |
|-----------|------|------|---------|
| `ScoreCard` | StatelessWidget | score_card.dart | Player score display |
| `ControlButton` | StatelessWidget | control_button.dart | Action buttons |
| `GlassContainer` | StatelessWidget | glass_container.dart | Glassmorphic wrapper |
| `WinDialog` | StatelessWidget | win_dialog.dart | Win celebration |
| `SettingsDialog` | StatelessWidget | settings_dialog.dart | Game settings |
| `RenameDialog` | StatefulWidget | rename_dialog.dart | Player names |
| `MatchHistoryDialog` | StatelessWidget | match_history_dialog.dart | Match history |

---

## Widget Module Structure

```
lib/
├── widgets/
│   ├── score_card.dart           # Score display with gestures
│   ├── control_button.dart       # Action button component
│   ├── glass_container.dart      # Glassmorphic container
│   ├── win_dialog.dart           # Win celebration dialog
│   ├── settings_dialog.dart      # Settings modal
│   ├── rename_dialog.dart        # Player name input
│   └── match_history_dialog.dart # Match history display
├── theme/
│   ├── theme.dart                # Re-exports
│   ├── app_colors.dart           # ThemeColors class
│   └── app_theme.dart            # AppThemes definitions
├── models/
│   ├── app_constants.dart        # Configuration
│   ├── game_state.dart           # Game state model
│   ├── score_action.dart         # Undo action
│   └── match_result.dart         # Match result
└── main.dart                     # App entry point
```

---

*Generated by BMAD document-project workflow (exhaustive scan)*
*Updated 2026-01-24 to reflect modularized architecture*
