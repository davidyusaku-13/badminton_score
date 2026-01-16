# UI Component Inventory

## Overview

The badminton score keeper uses a single-file architecture with modular widget builders. All UI components are defined in `lib/main.dart` with clear separation of concerns through private builder methods.

## Component Architecture

### Widget Hierarchy

```
BadmintonScoreApp (StatefulWidget)
└── MaterialApp
    └── ScoreScreen (StatefulWidget)
        └── Scaffold
            └── SafeArea
                └── Column
                    ├── _buildScoreSection() [75% height]
                    │   ├── Games Counter Row
                    │   │   ├── Left Player Info
                    │   │   ├── Serving Indicator
                    │   │   └── Right Player Info
                    │   └── Score Buttons Row
                    │       ├── _buildScoreButton() [Left]
                    │       └── _buildScoreButton() [Right]
                    └── _buildControlSection() [25% height]
                        └── Control Buttons Row
                            ├── _buildControlButton() [Left Minus]
                            ├── _buildControlButton() [Undo]
                            ├── _buildMenuButton() [Menu]
                            ├── _buildControlButton() [Swap]
                            └── _buildControlButton() [Right Minus]
```

## Core Components

### 1. Score Button Component

**Builder Method:** `_buildScoreButton()` (lib/main.dart:1465-1535)

**Purpose:** Large interactive score display with tap-to-increment functionality

**Parameters:**
- `score: int` - Current score value to display
- `onTap: VoidCallback` - Tap handler for score increment
- `color: Color` - Background color (primary/secondary from theme)
- `textColor: Color` - Text color for score display
- `isScaling: bool` - Animation state flag
- `isServing: bool` - Shows serving indicator border
- `servingColor: Color` - Border color when serving
- `isGamePoint: bool` - Triggers special game point styling
- `gamePointColor: Color` - Background color at game point

**Visual Features:**
- Material elevation: 8
- Border radius: 16px
- Font size: 256 (scaled with FittedBox)
- Font family: Poppins SemiBold (weight 600)
- Letter spacing: 2
- Scale animation: 1.0 → 0.95 on tap (100ms duration)
- Serving border: 4px solid accent color
- Game point glow: 20px blur, 2px spread

**Accessibility:**
- Semantics label: "Score: {score}. Tap to increment"
- Game point label: "Score: {score}. Game point! Tap to increment"
- Button role: true

**States:**
- Normal: Theme primary/secondary color
- Serving: 4px colored border
- Game Point: Gold/yellow background with glow effect
- Scaling: Transform.scale animation during tap

### 2. Control Button Component

**Builder Method:** `_buildControlButton()` (lib/main.dart:1537-1578)

**Purpose:** Outlined buttons for secondary actions (minus, undo, swap)

**Parameters:**
- `text: String` - Button label (-, ↩, ⇄)
- `onTap: VoidCallback` - Tap handler
- `color: Color` - Border and background tint color
- `textColor: Color` - Text color
- `semanticsLabel: String?` - Accessibility label
- `enabled: bool` - Disabled state for undo button

**Visual Features:**
- Style: OutlinedButton with custom styling
- Border: 2px solid (color or 30% alpha when disabled)
- Background: 10% alpha tint (5% when disabled)
- Border radius: 12px
- Font size: 50 (scaled with FittedBox)
- Font family: Poppins SemiBold (weight 600)
- Fixed height: 56px

**Accessibility:**
- Semantics label: Custom or text fallback
- Button role: true
- Enabled state: Communicated to screen readers

**States:**
- Enabled: Full color, 10% background tint
- Disabled: 30% alpha border, 5% background tint, 30% alpha text

### 3. Menu Button Component

**Builder Method:** `_buildMenuButton()` (lib/main.dart:741-779)

**Purpose:** Dual-gesture button for menu access and quick reset

**Parameters:**
- `color: Color` - Background color (accent from theme)
- `textColor: Color` - Text color for "⋮" symbol

**Visual Features:**
- Container with rounded corners (12px)
- Font size: 50 (scaled with FittedBox)
- Font family: Poppins SemiBold (weight 600)
- Symbol: "⋮" (vertical ellipsis)

**Gesture Handling:**
- `onTap()` - Opens menu dialog
- `onLongPress()` - Instant score reset with haptic feedback

**Accessibility:**
- Semantics label: "Menu button. Tap for menu, long press to reset scores"
- Button role: true

### 4. Grid Item Wrapper

**Builder Method:** `_buildGridItem()` (lib/main.dart:1456-1463)

**Purpose:** Consistent padding wrapper for all buttons

**Features:**
- Expanded widget for equal distribution
- Padding: 8px horizontal, 8px vertical (AppConstants.gridPadding)

## Layout Sections

### Score Section (75% Height)

**Builder Method:** `_buildScoreSection()` (lib/main.dart:912-1080)

**Components:**
1. **Games Counter Row** (Padding: 16px horizontal, 4px vertical)
   - Left player info (name + games won)
   - Center serving indicator with target score
   - Right player info (name + games won)

2. **Score Buttons Row** (Expanded)
   - Left score button (primary color)
   - Right score button (secondary color)

**Gesture Detection:**
- Horizontal swipe detection for theme switching
- Velocity threshold: 500 px/s (AppConstants.minSwipeVelocity)
- Swipe right: Previous theme
- Swipe left: Next theme

### Control Section (25% Height)

**Builder Method:** `_buildControlSection()` (lib/main.dart:1082-1180)

**Layout:**
- Container with padding: 16px horizontal, 12px vertical
- Row with 5 equally-spaced buttons
- Each button: 4px horizontal padding, 56px fixed height

**Buttons (Left to Right):**
1. Left Minus (-) - Decrement left score
2. Undo (↩) - Revert last score change
3. Menu (⋮) - Open menu / long press reset
4. Swap (⇄) - Swap sides
5. Right Minus (-) - Decrement right score

## Dialog Components

### 1. Menu Dialog

**Method:** `_showMenuDialog()` (lib/main.dart:1182-1276)

**Menu Items:**
- Player Names - Opens player names dialog
- Reset Score - Opens reset confirmation
- Reset Match - Resets scores and games
- Game Settings - Opens game settings dialog
- Change Theme - Opens theme selector
- Sound Toggle - Toggles audio feedback

**Styling:**
- AlertDialog with Poppins font
- ListTile items with icons
- Subtitle text: 12px font size

### 2. Theme Selector Dialog

**Method:** `_showThemeSelector()` (lib/main.dart:823-892)

**Features:**
- ListView of all available themes
- Color preview swatches (3 colors per theme)
- Checkmark on selected theme
- Tap to select and close

**Color Swatches:**
- Primary color (20x20px)
- Secondary color (20x20px)
- Background color (20x20px with border)

### 3. Reset Confirmation Dialog

**Method:** `_showResetConfirmation()` (lib/main.dart:788-821)

**Features:**
- Simple Yes/No confirmation
- Poppins font styling
- TextButton actions

### 4. Win Celebration Dialog

**Method:** `_showWinCelebration()` (lib/main.dart:455-571)

**Features:**
- Trophy icon (48px, amber color)
- Winner announcement
- Final score display in rounded container
- Target score subtitle
- Two action buttons:
  - "Continue Match" (TextButton, grey)
  - "New Game" (ElevatedButton, amber)

**Styling:**
- Black87 background
- 20px border radius
- Amber accent colors
- Poppins font throughout

### 5. Player Names Dialog

**Method:** `_showPlayerNamesDialog()` (lib/main.dart:1278-1365)

**Features:**
- Two TextField inputs (left and right player)
- OutlineInputBorder styling
- TextEditingController management
- Guaranteed disposal via `whenComplete()`

**Validation:**
- Empty names default to "Left" / "Right"
- Trimmed before saving

### 6. Game Settings Dialog

**Method:** `_showGameSettingsDialog()` (lib/main.dart:1367-1454)

**Features:**
- TextField for target score input
- Number-only keyboard
- Validation: Minimum 5 points
- Helper text showing minimum
- Info text about win conditions

**Validation:**
- Must be integer
- Must be >= AppConstants.minTargetScore (5)
- Shows SnackBar error if invalid

## Animation Components

### Scale Animation

**Controller:** `_scaleController` (lib/main.dart:321, 341-347)

**Configuration:**
- Duration: 100ms
- Curve: easeInOut
- Range: 1.0 → 0.95
- Trigger: Score button tap

**Usage:**
```dart
AnimatedBuilder(
  animation: _scaleAnimation,
  builder: (context, child) {
    final scale = isScaling ? _scaleAnimation.value : 1.0;
    return Transform.scale(scale: scale, child: child);
  },
)
```

## Responsive Design Features

### FittedBox Usage

**Applied to:**
- Score text (256px base size)
- Control button text (50px base size)
- Menu button text (50px base size)

**Purpose:**
- Prevents text overflow on different screen sizes
- Maintains aspect ratio while scaling
- Ensures readability across devices

**Configuration:**
```dart
FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(...),
)
```

### Flexible Layout

**Flex Distribution:**
- Score section: 75 (AppConstants.scoreSectionFlex)
- Control section: 25 (AppConstants.controlSectionFlex)

**Button Distribution:**
- All control buttons: Expanded widgets (equal width)
- Score buttons: Expanded widgets (equal width)

## Accessibility Features

### Semantics Labels

**All interactive elements include:**
- Descriptive labels for screen readers
- Button role indicators
- State information (enabled/disabled)
- Context-aware descriptions (e.g., "Game point!")

**Examples:**
- Score buttons: "Score: 5. Tap to increment"
- Undo button: "Undo last score change"
- Menu button: "Menu button. Tap for menu, long press to reset scores"
- Serving indicator: "Left serving" or "Right serving"

### Visual Accessibility

**High Contrast:**
- All themes tested for WCAG AA compliance
- Minimum contrast ratios maintained
- Clear visual hierarchy

**Touch Targets:**
- Score buttons: Large (75% of screen height)
- Control buttons: 56px height (meets minimum 48px)
- Adequate spacing between buttons (8px padding)

## Material Design Compliance

### Elevation System

**Score Buttons:**
- Elevation: 8
- Shadow color: black26
- Creates depth and hierarchy

**Control Buttons:**
- Outlined style (no elevation)
- 2px border for definition

### Border Radius

**Consistent Rounding:**
- Score buttons: 16px
- Control buttons: 12px
- Menu button: 12px
- Dialogs: 20px (win celebration), 8px (others)

### Color System

**Theme-Based:**
- Primary: Left score button
- Secondary: Right score button
- Surface: Control button backgrounds
- Accent: Menu button, serving indicator
- Game Point: Special state color (gold/yellow)

## Component Reusability

### Builder Pattern

**All components use private builder methods:**
- `_buildScoreButton()` - Reused for left and right scores
- `_buildControlButton()` - Reused for all control buttons
- `_buildGridItem()` - Wrapper for consistent spacing
- `_buildMenuButton()` - Single instance in control section

**Benefits:**
- Consistent styling across components
- Easy maintenance and updates
- Clear separation of concerns
- Reduced code duplication

### Parameter-Driven Customization

**Components accept parameters for:**
- Colors (from theme)
- Text content
- Callbacks (onTap handlers)
- State flags (isScaling, isServing, isGamePoint)
- Accessibility labels

## Performance Optimizations

### Const Constructors

**Used for:**
- EdgeInsets (AppConstants.gridPadding)
- Theme color definitions
- Static text widgets

### Cached Values

**Precomputed:**
- Theme keys list (AppThemes.themeKeys)
- Audio source (AssetSource preloaded)
- SharedPreferences instance (cached)

### Minimal Rebuilds

**setState() scoped to:**
- Only affected state variables
- Narrow rebuild boundaries
- Efficient widget tree updates

## Asset Integration

### Fonts

**Poppins Font Family:**
- Regular (400 weight) - Body text
- SemiBold (600 weight) - Scores, buttons, headings

**Usage:**
```dart
TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w600,
)
```

### Audio

**Beep Sound:**
- Asset: `assets/beep.mp3`
- Loaded via: `AssetSource('beep.mp3')`
- Preloaded in initState()
- Plays on score increments only

### Images

**Splash Screen:**
- Asset: `assets/splash.png`
- Used for: App icon and splash screen
- Configured in: pubspec.yaml

## Component Summary

| Component | Type | Location | Purpose |
|-----------|------|----------|---------|
| ScoreButton | Interactive Display | main.dart:1465 | Large score display with tap increment |
| ControlButton | Action Button | main.dart:1537 | Outlined buttons for secondary actions |
| MenuButton | Dual-Gesture Button | main.dart:741 | Menu access and quick reset |
| GridItem | Layout Wrapper | main.dart:1456 | Consistent padding for buttons |
| MenuDialog | Modal | main.dart:1182 | Settings and actions menu |
| ThemeSelector | Modal | main.dart:823 | Theme selection with previews |
| WinCelebration | Modal | main.dart:455 | Game win announcement |
| PlayerNamesDialog | Input Modal | main.dart:1278 | Player name configuration |
| GameSettingsDialog | Input Modal | main.dart:1367 | Target score configuration |
| ResetConfirmation | Confirmation Modal | main.dart:788 | Reset score confirmation |

## Design System

### Typography Scale

- **Mega (256px):** Score display
- **Large (50px):** Control buttons, menu button
- **Medium (30px):** Button text in dialogs
- **Small (14px):** Player names, serving indicator
- **Tiny (12px):** Subtitles, helper text

### Spacing System

- **Section padding:** 16px horizontal, 12px vertical
- **Button padding:** 8px horizontal, 8px vertical
- **Compact padding:** 4px horizontal, 4px vertical
- **Button spacing:** 4px between buttons

### Color Roles

- **Primary:** Main action (left score)
- **Secondary:** Secondary action (right score)
- **Surface:** Control backgrounds
- **Accent:** Menu, serving indicator
- **Game Point:** Special state (gold/yellow)
- **Background:** Screen background
- **On Surface:** Text on surfaces
